#! /bin/bash

PRGNAME="gnutls"

### GnuTLS (GNU Transport Layer Security Library)
# Реализация протоколов TLS и SSL предназначенная для предоставления
# приложениям API для обеспечения надежной связи по протоколам транспортного
# уровня

# http://www.linuxfromscratch.org/blfs/view/9.0/postlfs/gnutls.html

# Home page: http://www.gnu.org/software/gnutls/
# Download:  https://www.gnupg.org/ftp/gcrypt/gnutls/v3.6/gnutls-3.6.9.tar.xz

# Required:    nettle
# Recommended: make-ca
#              libunistring
#              libtasn1
#              p11-kit
# Optional:    doxygen
#              gtk-doc
#              guile
#              libidn or libidn2
#              net-tools (used during the test suite)
#              texlive or install-tl-unx
#              unbound (to build the DANE library)
#              valgrind (used during the test suite)
#              autogen
#              cmocka
#              datefudge (for test suite if the DANE library is built)
#              trousers (Trusted Platform Module support)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure                                     \
    --prefix=/usr                               \
    --disable-guile                             \
    --with-default-trust-store-pkcs11="pkcs11:" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

# документация
make -C doc/reference install-data-local
mkdir -p "${TMP_DIR}/usr/share/gtk-doc/html/gnutls"
cp -Rv /usr/share/gtk-doc/html/gnutls/* \
    "${TMP_DIR}/usr/share/gtk-doc/html/gnutls"

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
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
