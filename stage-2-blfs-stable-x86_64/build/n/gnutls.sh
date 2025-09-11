#! /bin/bash

PRGNAME="gnutls"

### GnuTLS (GNU Transport Layer Security Library)
# Реализация протоколов TLS и SSL предназначенная для предоставления
# приложениям API для обеспечения надежной связи по протоколам транспортного
# уровня

# Required:    nettle
# Recommended: make-ca
#              libunistring
#              libtasn1
#              p11-kit
# Optional:    brotli
#              doxygen
#              gtk-doc                      (для сборки API документации)
#              libidn или libidn2
#              libseccomp
#              net-tools                    (для тестов)
#              texlive или install-tl-unx
#              unbound                      (для создания libgnutls-dane.so и утилиты danetool)
#              valgrind                     (для тестов)
#              autogen                      (https://ftp.gnu.org/gnu/autogen/)
#              cmocka                       (для тестов библиотеки DANE) https://cmocka.org/
#              datefudge                    (для тестов библиотеки DANE) http://ftp.debian.org/debian/pool/main/d/datefudge/
#              leancrypto                   (https://github.com/smuellerDD/leancrypto)
#              trousers                     (поддержка Trusted Platform Module) https://sourceforge.net/projects/trousers/files/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2,3)"
cd "${PRGNAME}-${MAJ_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -p "${TMP_DIR}"

# указываем GnuTLS использовать хранилище доверия PKCS#11 по умолчанию
#    --with-default-trust-store-pkcs11="pkcs11:"
# включаем совместимость с OpenSSL и собираем библиотеку libgnutls-openssl.so
#    --enable-openssl-compatibility
./configure                                         \
    --prefix=/usr                                   \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" \
    --with-default-trust-store-pkcs11="pkcs11:"     \
    --enable-openssl-compatibility || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU Transport Layer Security Library)
#
# The GnuTLS package contains libraries and userspace tools which provide a
# secure layer over a reliable transport layer. Currently the GnuTLS library
# implements the proposed standards by the IETFs TLS working group. Quoting
# from the TLS protocol specification:
#
#    "The TLS protocol provides communications privacy over the Internet. The
#     protocol allows client/server applications to communicate in a way that
#     is designed to prevent eavesdropping, tampering, or message forgery."
#
# GnuTLS provides support for TLS 1.3, TLS 1.2, TLS 1.1, TLS 1.0, and SSL 3.0
# protocols, TLS extensions, including server name and max record size.
# Additionally, the library supports authentication using the SRP protocol,
# X.509 certificates and OpenPGP keys, along with support for the TLS
# Pre-Shared-Keys (PSK) extension, the Inner Application (TLS/IA) extension and
# X.509 and OpenPGP certificate handling.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
