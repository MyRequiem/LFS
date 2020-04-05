#! /bin/bash

PRGNAME="curl"

### cURL
# Утилита командной строки, позволяющая взаимодействовать с множеством
# различных серверов по множеству различных протоколов: FTP, FTPS, HTTP, HTTPS,
# SCP, SFTP, TFTP, TELNET, DICT, LDAP, LDAPS, FILE

# http://www.linuxfromscratch.org/blfs/view/9.0/basicnet/curl.html

# Home page: https://curl.haxx.se/
# Download:  https://curl.haxx.se/download/curl-7.69.1.tar.xz

# Required:    no
# Recommended: make-ca-1.4 (runtime)
# Optional:    c-ares
#              gnutls
#              libidn2
#              libpsl
#              libssh2
#              MIT Kerberos
#              v5
#              nghttp2
#              openldap
#              samba
#              brotli
#              libmetalink
#              librtmp
#              spnego
#              stunnel (для HTTPS and FTPS тестов)
#              valgrind

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure                    \
    --prefix=/usr              \
    --disable-static           \
    --enable-threaded-resolver \
    --with-ca-path=/etc/ssl/certs || exit 1

make || exit 1
# известно, что в LFS системе тесты 323 and 1560 не проходят
# make test
make install
make install DESTDIR="${TMP_DIR}"

rm -rf docs/examples/.deps
find docs \( -name "Makefile*" -o -name "*.1" -o -name "*.3" \) -exec rm {} \;

install -v -d -m755 "/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -d -m755 "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
cp -v -R docs/*     "/usr/share/doc/${PRGNAME}-${VERSION}"
cp -v -R docs/*     "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command line URL data transfer tool)
#
# Curl is a command line tool for transferring data specified with URL syntax.
# The command is designed to work without user interaction or any kind of
# interactivity. Curl offers a busload of useful tricks like proxy support,
# user authentication, ftp upload, HTTP post, SSL (https:) connections,
# cookies, file transfer resume and more.
#
# Home page: https://curl.haxx.se/
# Download:  https://curl.haxx.se/download/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
