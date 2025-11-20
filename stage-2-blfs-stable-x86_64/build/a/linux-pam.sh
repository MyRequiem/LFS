#! /bin/bash

PRGNAME="linux-pam"
ARCH_NAME="Linux-PAM"

### Linux PAM (Pluggable Authentication Modules)
# Модульный фреймворк, который позволяет системным администраторам гибко
# настраивать и централизованно управлять методами аутентификации пользователей
# в Linux

# Required:    no
# Recommended: no
# Optional:    libnsl
#              libtirpc
#              rpcsvc-proto
#              berkeley-db                  (https://anduin.linuxfromscratch.org/BLFS/bdb/db-5.3.28.tar.gz)
#              libaudit                     (https://github.com/linux-audit/audit-userspace)
#              libeconf                     (https://github.com/openSUSE/libeconf)
#              --- для документации ---
#              docbook-xml
#              docbook-xsl
#              fop                          (pdf)
#              libxslt
#              lynx                         (plain text)

### Конфигурация ядра
#    CONFIG_AUDIT=y

###
# IMPORTANT
###
# После установки/переустановки/обновления 'linux-pam' пакет 'shadow'
# ОБЯЗАТЕЛЬНО должен быть пересобран и сконфигурирован для работы с Linux PAM
#
# Нужно быть осторожными при изменении файлов в /etc/pam.d/, иначе система
# может стать совершенно непригодной для использования
#
# Переустановка/обновление данного пакета перезаписывает файлы конфигурации:
#    /etc/security/
#    /etc/environment
# Нужно ОБЯЗАТЕЛЬНО сделать их резервные копии

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/config_file_processing.sh"               || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/pam.d"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

chmod -v 4755 "${TMP_DIR}/usr/sbin/unix_chkpwd"

# удалим бесполезный каталог
rm -rf "${TMP_DIR}/usr/lib/systemd"

###
# Конфигурация Linux-PAM
###

# Конфиги:
#    /etc/security/*
#    /etc/pam.d/*

SYSTEM_AUTH="/etc/pam.d/system-auth"
cat << EOF > "${TMP_DIR}${SYSTEM_AUTH}"
auth      required    pam_unix.so

EOF

if [ -f "${SYSTEM_AUTH}" ]; then
    mv "${SYSTEM_AUTH}" "${SYSTEM_AUTH}.old"
fi

SYSTEM_ACCOUNT="/etc/pam.d/system-account"
cat << EOF > "${TMP_DIR}${SYSTEM_ACCOUNT}"
account   required    pam_unix.so

EOF

if [ -f "${SYSTEM_ACCOUNT}" ]; then
    mv "${SYSTEM_ACCOUNT}" "${SYSTEM_ACCOUNT}.old"
fi

SYSTEM_SESSION="/etc/pam.d/system-session"
cat << EOF > "${TMP_DIR}${SYSTEM_SESSION}"
session   required    pam_unix.so

EOF

if [ -f "${SYSTEM_SESSION}" ]; then
    mv "${SYSTEM_SESSION}" "${SYSTEM_SESSION}.old"
fi

SYSTEM_PASSWORD="/etc/pam.d/system-password"
cat << EOF > "${TMP_DIR}${SYSTEM_PASSWORD}"
# - use yescrypt hash for encryption
# - use shadow
# - try to use any previously defined authentication token (chosen password)
#    set by any prior module
password  required    pam_unix.so       yescrypt shadow try_first_pass

EOF

if [ -f "${SYSTEM_PASSWORD}" ]; then
    mv "${SYSTEM_PASSWORD}" "${SYSTEM_PASSWORD}.old"
fi

# добавим ограничительный конфиг /etc/pam.d/other с которым приложения,
# поддерживающие PAM, не будут запускаться, если не существует файла
# конфигурации специально для этого приложения
OTHER="/etc/pam.d/other"
cat << EOF > "${TMP_DIR}${OTHER}"
auth        required        pam_warn.so
auth        required        pam_deny.so
account     required        pam_warn.so
account     required        pam_deny.so
password    required        pam_warn.so
password    required        pam_deny.so
session     required        pam_warn.so
session     required        pam_deny.so

EOF

if [ -f "${OTHER}" ]; then
    mv "${OTHER}" "${OTHER}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${SYSTEM_AUTH}"
config_file_processing "${SYSTEM_ACCOUNT}"
config_file_processing "${SYSTEM_SESSION}"
config_file_processing "${SYSTEM_PASSWORD}"
config_file_processing "${OTHER}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Pluggable Authentication Modules)
#
# The Linux PAM package contains Pluggable Authentication Modules used by the
# local system administrator to control how application programs authenticate
# users
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
