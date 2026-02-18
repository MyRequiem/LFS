#! /bin/bash

PRGNAME="keyutils"

### keyutils (Kernel key management utilities)
# Набор утилит для управления хранилищем ключей в ядре, которое может
# использоваться файловыми системами, блочными устройствами и т.д.

# Required:    no
# Recommended: no
# Optional:    lsb-tools    (для тестов)

# Конфиги:
#    /etc/request-key.conf
#    /etc/request-key.d/*

### Параметры ядра
#    CONFIG_KEYS=y
#    CONFIG_BIG_KEYS=y
#    CONFIG_KEY_DH_OPERATIONS=y
#    CONFIG_CRYPTO=y
#    CONFIG_CRYPTO_RSA=m|y
#    CONFIG_CRYPTO_SHA1=m|y
#    CONFIG_ASYMMETRIC_KEY_TYPE=y
#    CONFIG_ASYMMETRIC_PUBLIC_KEY_SUBTYPE=y
#    CONFIG_X509_CERTIFICATE_PARSER=y
#    CONFIG_SYSTEM_TRUSTED_KEYRING=y
#    CONFIG_SECONDARY_TRUSTED_KEYRING=y
#    CONFIG_SYSTEM_BLACKLIST_KEYRING=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make || exit 1

# не устанавливать статическую библиотеку
#    NO_ARLIB=1
make                \
    NO_ARLIB=1      \
    LIBDIR=/usr/lib \
    BINDIR=/usr/bin \
    SBINDIR=/usr/sbin install DESTDIR="${TMP_DIR}"

# тесты нужно проводить после установки пакета в систему
# make -k test

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Kernel key management utilities)
#
# Keyutils is a set of utilities for managing the key retention facility in the
# kernel, which can be used by filesystems, block devices and more to gain and
# retain the authorization and encryption keys required to perform secure
# operations
#
# Home page: https://www.kernel.org/
# Download:  https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/${PRGNAME}.git/snapshot/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
