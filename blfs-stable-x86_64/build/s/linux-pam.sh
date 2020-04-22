#! /bin/bash

PRGNAME="linux-pam"
ARCH_NAME="Linux-PAM"
DOCBOOK_XML_VERION="4.5"
DOCBOOK_XSL_VERSION="1.79.2"

### Linux-PAM (Linux Pluggable Authentication Modules)
# Набор разделяемых библиотек (подключаемыx модулей аутентификации), которые
# позволяют интегрировать различные низкоуровневые методы аутентификации в виде
# единого высокоуровневого API, тем самым предоставляя единые механизмы для
# управления, встраивания прикладных программ в процесс аутентификации.
# Является одной из частей стандартного механизма обеспечения безопасности
# UNIX-систем

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/linux-pam.html

# Home page: http://www.linux-pam.org/
# Download:  https://github.com/linux-pam/linux-pam/releases/download/v1.3.1/Linux-PAM-1.3.1.tar.xz
# DOCS:      https://github.com/linux-pam/linux-pam/releases/download/v1.3.1/Linux-PAM-1.3.1-docs.tar.xz

# Required: no
# Optional: berkeley-db
#           cracklib
#           libtirpc
#           prelude (https://www.prelude-siem.org/)
#           docbook-xml
#           docbook-xsl
#           fop
#           libxslt
#           lynx или w3m (http://w3m.sourceforge.net/)

###
# ВАЖНО !!!
###
# После установки и конфигурирования Linux-PAM необходимо пересобрать и
# переустановить пакет shadow
#
# Переустановка/обновление Linux PAM
# ----------------------------------
# Если Linux PAM уже установлен в системе, нужно быть осторожными при изменении
# файлов в /etc/pam.d/, т.к. система может стать полностью непригодной для
# использования.
#
# Также необходимо помнить, что 'make install' для данного пакета перезапишет
# файлы конфигурации в /etc/security/* и /etc/environment, поэтому лучше
# сделать их резервную копию

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/config_file_processing.sh"               || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/{lib,etc/pam.d}

# распакуем документацию
tar -xvf "${SOURCES}/_${ARCH_NAME}-${VERSION}-docs.tar.xz" --strip-components=1

# для пересборки документации поправим скрипт configure для поиска
# установленного браузера lynx вместо links
red -e 's/dummy links/dummy lynx/'                                     \
    -e 's/-no-numbering -no-references/-force-html -nonumbers -stdin/' \
    -i configure

# если опциональные зависимости
#    docbook-xml
#    docbook-xsl
#    libxslt
#    lynx или w3m
#    fop
# установлены, то собираем man-страницы и html и pdf документацию
DOCUMENTATION="--disable-regenerate-docu"
BROWSER=""
LYNX=""
W3M=""
command -v lynx &>/dev/null && LYNX="true"
command -v w3m  &>/dev/null && W3M="true"
[[ -n "${LYNX}" || -n "${W3M}" ]] && BROWSER="true"

ls /var/log/packages/docbook-xml-${DOCBOOK_XML_VERION} &>/dev/null && \
    ls /var/log/packages/docbook-xsl-${DOCBOOK_XSL_VERSION} &>/dev/null && \
    command -v xslt-config &>/dev/null && \
    [ -n "${BROWSER}" ] && \
    command -v fop &>/dev/null && DOCUMENTATION="--enable-regenerate-docu"

# устанавливаем модули PAM в /lib/security
#    --enable-securedir=/lib/security
./configure                          \
    --prefix=/usr                    \
    --sysconfdir=/etc                \
    --libdir=/usr/lib                \
    --enable-securedir=/lib/security \
    "${DOCUMENTATION}"               \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# создадим файл конфигурации /etc/pam.d/other, но только если он еще НЕ
# существует (первая установка пакета). Этот файл требуется для прохождения
# сборочных тестов
install -v -m755 -d /etc/pam.d
FIRST_INSTALL="false"
PAM_D_OTHER="/etc/pam.d/other"
if ! [ -f "${PAM_D_OTHER}" ]; then
    FIRST_INSTALL="true"

cat > "${PAM_D_OTHER}" << "EOF"
auth     required       pam_deny.so
account  required       pam_deny.so
password required       pam_deny.so
session  required       pam_deny.so
EOF
fi

# для данного пакета лучше запускать тесты и внимательно отслеживать их
# прохождение
# make check

# если это первая установка пакета, то удалим созданный конфиг /etc/pam.d/other
[[ "x${FIRST_INSTALL}" == "xtrue" ]] && rm -fv /etc/pam.d/*

# устанавливаем пакет
make install
make install DESTDIR="${TMP_DIR}"

# вспомогательная утилита unix_chkpwd должна быть настроена так, чтобы процессы
# без полномочий root могли получить доступ к файлу /etc/shadow
chmod -v 4755 /sbin/unix_chkpwd
chmod -v 4755 "${TMP_DIR}/sbin/unix_chkpwd"

for LIB in pam pam_misc pamc; do
    mv -v "/usr/lib/lib${LIB}".so.* /lib
    ln -sfv "../../lib/$(readlink /usr/lib/lib${LIB}.so)" \
        "/usr/lib/lib${LIB}.so"
done

(
    cd "${TMP_DIR}/usr/lib" || exit 1
    for LIB in pam pam_misc pamc; do
        mv -v "lib${LIB}".so.* "${TMP_DIR}/lib"
        ln -sfv "../../lib/$(readlink lib${LIB}.so)" "lib${LIB}.so"
    done
)

### Конфигурация Linux-PAM
# Конфиги находятся в директориях:
#    /etc/security/
#    /etc/pam.d/
# ----------------------------- /etc/pam.d/other -------------------------------
if [ -f "${PAM_D_OTHER}" ]; then
    mv "${PAM_D_OTHER}" "${PAM_D_OTHER}.old"
fi

cat << EOF > "${PAM_D_OTHER}"
# Begin ${PAM_D_OTHER}

auth        required        pam_warn.so
auth        required        pam_deny.so
account     required        pam_warn.so
account     required        pam_deny.so
password    required        pam_warn.so
password    required        pam_deny.so
session     required        pam_warn.so
session     required        pam_deny.so

# End ${PAM_D_OTHER}
EOF

config_file_processing "${PAM_D_OTHER}"
cp "${PAM_D_OTHER}" "${TMP_DIR}/etc/pam.d/"
# ------------------------ /etc/pam.d/system-account ---------------------------
SYS_ACCOUNT="/etc/pam.d/system-account"
if [ -f "${SYS_ACCOUNT}" ]; then
    mv "${SYS_ACCOUNT}" "${SYS_ACCOUNT}.old"
fi

cat << EOF > "${SYS_ACCOUNT}"
# Begin ${SYS_ACCOUNT}

account   required    pam_unix.so

# End ${SYS_ACCOUNT}
EOF

config_file_processing "${SYS_ACCOUNT}"
cp "${SYS_ACCOUNT}" "${TMP_DIR}/etc/pam.d/"
# -------------------------- /etc/pam.d/system-auth ----------------------------
SYSTEM_AUTH="/etc/pam.d/system-auth"
cat << EOF > "${SYSTEM_AUTH}"
# Begin ${SYSTEM_AUTH}

auth      required    pam_unix.so

# End ${SYSTEM_AUTH}
EOF

config_file_processing "${SYSTEM_AUTH}"
cp "${SYSTEM_AUTH}" "${TMP_DIR}/etc/pam.d/"
# ------------------------ /etc/pam.d/system-session ---------------------------
SYSTEM_SESSION="/etc/pam.d/system-session"
cat << EOF > "${SYSTEM_SESSION}"
# Begin ${SYSTEM_SESSION}

session   required    pam_unix.so

# End ${SYSTEM_SESSION}
EOF

config_file_processing "${SYSTEM_SESSION}"
cp "${SYSTEM_SESSION}" "${TMP_DIR}/etc/pam.d/"
# ------------------------ /etc/pam.d/system-password --------------------------
SYSTEM_PASSWORD="/etc/pam.d/system-password"
# если установлена опциональная зависимость cracklib
if command -v cracklib-check &>/dev/null; then
    cat << EOF > "${SYSTEM_PASSWORD}"
# Begin ${SYSTEM_PASSWORD}

# check new passwords for strength (man pam_cracklib)
password  required    pam_cracklib.so    authtok_type=UNIX retry=1 difok=5 \
                                         minlen=9 dcredit=1 ucredit=1 \
                                         lcredit=1 ocredit=1 minclass=0 \
                                         maxrepeat=0 maxsequence=0 \
                                         maxclassrepeat=0 \
                                         dictpath=/lib/cracklib/pw_dict

# use sha512 hash for encryption, use shadow, and use the
# authentication token (chosen password) set by pam_cracklib
# above (or any previous modules)
password  required    pam_unix.so        sha512 shadow use_authtok

# End ${SYSTEM_PASSWORD}
EOF
else
    # cracklib не установлен
    cat << EOF > "${SYSTEM_PASSWORD}"
# Begin ${SYSTEM_PASSWORD}

# use sha512 hash for encryption, use shadow, and try to use any previously
# defined authentication token (chosen password) set by any prior module
password  required    pam_unix.so       sha512 shadow try_first_pass

# End ${SYSTEM_PASSWORD}
EOF
fi

config_file_processing "${SYSTEM_PASSWORD}"
cp "${SYSTEM_PASSWORD}" "${TMP_DIR}/etc/pam.d/"
# ------------------------------------------------------------------------------

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Linux Pluggable Authentication Modules)
#
# Linux Pluggable Authentication Modules (PAM) provide dynamic authentication
# support for applications and services in a Linux system. Linux PAM is evolved
# from the Unix Pluggable Authentication Modules architecture.
#
# Home page: http://www.linux-pam.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
