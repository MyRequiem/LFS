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
# Optional:    doxygen
#              gtk-doc (для сборки API документации, см. опции ниже)
#              guile
#              libidn or libidn2
#              libseccomp
#              net-tools (для тестов)
#              texlive or install-tl-unx
#              unbound (для создания libgnutls-dane.so и утилиты danetool)
#              valgrind (для тестов)
#              autogen (https://ftp.gnu.org/gnu/autogen/)
#              cmocka (для тестов библиотеки DANE) https://cmocka.org/
#              datefudge (для тестов библиотеки DANE) http://ftp.debian.org/debian/pool/main/d/datefudge/
#              trousers (поддержка Trusted Platform Module) https://sourceforge.net/projects/trousers/files/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -p "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
IDN="--without-idn"
UNBOUND="--disable-libdane"
VALGRIND="--disable-valgrind-tests"
TROUSERS="--without-tpm"
GUILE="--disable-guile"

# command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"
command -v idn      &>/dev/null && IDN="--with-idn"
command -v idn2     &>/dev/null && IDN="--with-idn"
command -v unbound  &>/dev/null && UNBOUND="--enable-libdane"
command -v valgrind &>/dev/null && VALGRIND="--enable-valgrind-tests"
command -v tcsd     &>/dev/null && TROUSERS="--with-tpm"
command -v guile    &>/dev/null && GUILE="--enable-guile"

# GnuTLS не поддерживает guile, поэтому отключаем его
#    --disable-guile
# включаем совместимость с OpenSSL и собираем библиотеку libgnutls-openssl.so
#    --enable-openssl-compatibility
# указываем GnuTLS использовать хранилище доверия PKCS#11 по умолчанию
#    --with-default-trust-store-pkcs11="pkcs11:"
./configure                                     \
    --prefix=/usr                               \
    --enable-openssl-compatibility              \
    --with-default-trust-store-pkcs11="pkcs11:" \
    "${GTK_DOC}"                                \
    "${IDN}"                                    \
    "${UNBOUND}"                                \
    "${VALGRIND}"                               \
    "${TROUSERS}"                               \
    "${GUILE}"                                  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# в документации только *.png файлы
rm -rf "${TMP_DIR}/usr/share/doc"

# документация GTK
if [[ "x${GTK_DOC}" == "x--enable-gtk-doc" ]]; then
    DOCS="/usr/share/gtk-doc/html/gnutls"
    mkdir -p "${TMP_DIR}${DOCS}"
    make -C doc/reference install-data-local DESTDIR="${TMP_DIR}"
fi

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
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://www.gnupg.org/ftp/gcrypt/${PRGNAME}/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
