#! /bin/bash

PRGNAME="gpgme"

### GPGME (GnuPG Made Easy)
# C-библиотека, предназначенная для упрощения доступа приложений к функциям
# GnuPG. Она предлагает высокоуровневый криптографический API для функций
# шифрования/дешифрования, цифровых подписей, их верификации и управления
# ключами. В настоящее время библиотека служит интерфейсом к GnuPG

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/gpgme.html

# Home page: https://gnupg.org/software/gpgme/index.html
# Download:  https://www.gnupg.org/ftp/gcrypt/gpgme/gpgme-1.13.1.tar.bz2

# Required: libassuan
# Optional: doxygen (для сборки API документации)
#           graphviz (для сборки API документации)
#           gnupg (если qt5 или swig установлены, используется для тестов)
#           clisp
#           python2
#           qt5  (для языковых привязок и сборки библиотеки libqgpgme.so)
#           swig (для языковых привязок)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GNUPG="--disable-gpg-test"
command -v gpg &>/dev/null && GNUPG="--enable-gpg-test"

./configure       \
    --prefix=/usr \
    "${GNUPG}" || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

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
