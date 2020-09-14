#! /bin/bash

PRGNAME="cryptsetup"

### cryptsetup (utility for setting up encrypted filesystems)
# LUKS (от Linux Unified Key Setup) - спецификация формата шифрования дисков,
# которая доступна посредством утилиты cryptsetup и используется для
# прозрачного шифрования блочных устройств используя API ядра Linux

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/cryptsetup.html

# Home page: https://gitlab.com/cryptsetup/cryptsetup
# Download:  https://www.kernel.org/pub/linux/utils/cryptsetup/v2.0/cryptsetup-2.0.6.tar.xz

# Required: json-c
#           libgcrypt
#           lvm2
#           popt
# Optional: libpwquality
#           python2
#           passwdqc (https://www.openwall.com/passwdqc/)

### Конфигурация ядра
#    CONFIG_MD=y
#    CONFIG_BLK_DEV_DM=m|y
#    CONFIG_DM_CRYPT=m|y
#    CONFIG_CRYPTO_XTS=m|y
#    CONFIG_CRYPTO_SHA256=m|y
#    CONFIG_CRYPTO_AES=m|y
#    CONFIG_CRYPTO_AES_X86_64=m|y
#    CONFIG_CRYPTO_USER_API_SKCIPHER=m|y
#    CONFIG_CRYPTO_TWOFISH=m|y

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --with-crypto_backend=openssl || exit 1

make || exit 1

# Некоторые тесты могут не пройти, если вышеуказанные параметры конфигурации
# ядра не установлены. Известно, что один из 12 тестов не проходит.
#
# make check

make install
make install DESTDIR="${TMP_DIR}"

MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (utility for setting up encrypted filesystems)
#
# LUKS is a standard for cross-platform hard disk encryption. It provides
# secure management of multiple userpasswords and stores setup information in
# the partition header. LUKS for dm-crypt is now implemented in cryptsetup
# replacing the original cryptsetup. It provides all the functionally of the
# original version plus all LUKS features.
#
# Home page: https://gitlab.com/${PRGNAME}/${PRGNAME}
# Download:  https://www.kernel.org/pub/linux/utils/${PRGNAME}/v${MAJ_VER}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
