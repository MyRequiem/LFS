#! /bin/bash

PRGNAME="gpgme"

### GPGME (GnuPG Made Easy)
# Прослойка (библиотека), которая упрощает программам использование шифрования
# GnuPG. С её помощью приложения могут легко подписывать письма или шифровать
# файлы. В настоящее время служит интерфейсом к GnuPG.

# Required:    libassuan
# Recommended: gnupg
# Optional:    doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

../configure      \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make -k check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GnuPG Made Easy)
#
# GPGME (GnuPG Made Easy) is a C language library that allows to add support
# for cryptography to a program. It is designed to make access to public key
# crypto engines like GnuPG or GpgSM easier for applications. GPGME provides a
# high-level crypto API for encryption, decryption, signing, signature
# verification and key management. GPGME uses GnuPG and GpgSM as its backends
# to support OpenPGP and the Cryptographic Message Syntax (CMS).
#
# Home page: https://gnupg.org/software/${PRGNAME}/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
