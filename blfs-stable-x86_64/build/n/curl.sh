#! /bin/bash

PRGNAME="curl"

### cURL (command line URL data transfer tool)
# Утилита командной строки, позволяющая взаимодействовать с множеством
# различных серверов по множеству различных протоколов: FTP, FTPS, HTTP, HTTPS,
# SCP, SFTP, TFTP, TELNET, DICT, LDAP, LDAPS, FILE

# http://www.linuxfromscratch.org/blfs/view/svn/basicnet/curl.html

# Home page: https://curl.haxx.se/
# Download:  https://curl.haxx.se/download/curl-7.71.1.tar.xz

# Required:    no
# Recommended: make-ca (runtime)
# Optional:    brotli
#              c-ares
#              gnutls
#              libidn2
#              libpsl
#              libssh2
#              mit-kerberos-v5
#              nghttp2
#              openldap
#              samba
#              impacket    (https://www.secureauth.com/labs/open-source-tools/impacket)
#              libmetalink (https://launchpad.net/libmetalink/)
#              librtmp     (http://rtmpdump.mplayerhq.hu/)
#              ngtcp2      (https://github.com/ngtcp2/ngtcp2/)
#              quiche      (https://github.com/cloudflare/quiche)
#              spnego      (http://spnego.sourceforge.net/)
#              stunnel     (для HTTPS and FTPS тестов)
#              valgrind

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

C_ARES="--disable-ares"
LIBIDN2="--without-libidn2"
LIBPSL="--without-libpsl"
LIBSSH2="--without-libssh2"
NGHTTP2="--without-nghttp2"
LIBMETALINK="--without-libmetalink"
GNUTLS="--without-gnutls"
OPENLDAP="--disable-ldap"
SAMBA="--disable-smb"
LIBRTMP="--without-librtmp"

[ -x /usr/lib/libcares.so ]       && C_ARES="--enable-ares"
[ -x /usr/lib/libidn2.so ]        && LIBIDN2="--with-libidn2=/usr"
[ -x /usr/lib/libpsl.so ]         && LIBPSL="--with-libpsl"
[ -x /usr/lib/libssh2.so ]        && LIBSSH2="--with-libssh2"
[ -x /usr/lib/libnghttp2.so ]     && NGHTTP2="--with-nghttp2=/usr"
[ -x /usr/lib/libmetalink.so ]    && LIBMETALINK="--with-libmetalink=/usr"
command -v gnutls-cli &>/dev/null && GNUTLS="--with-gnutls=/usr"
command -v ldapadd    &>/dev/null && OPENLDAP="--enable-ldap"
command -v samba      &>/dev/null && SAMBA="--enable-smb"
command -v rtmpdump   &>/dev/null && LIBRTMP="--with-librtmp=/usr"

./configure                    \
    --prefix=/usr              \
    --disable-static           \
    --enable-threaded-resolver \
    "${C_ARES}"                \
    "${LIBIDN2}"               \
    "${LIBPSL}"                \
    "${LIBSSH2}"               \
    "${NGHTTP2}"               \
    "${LIBMETALINK}"           \
    "${GNUTLS}"                \
    "${OPENLDAP}"              \
    "${SAMBA}"                 \
    "${LIBRTMP}"               \
    --with-ca-path=/etc/ssl/certs || exit 1

make || exit 1
# make test
make install
make install DESTDIR="${TMP_DIR}"

rm -rf docs/examples/.deps
find docs \( -name "Makefile*" -o -name "*.1" -o -name "*.3" \) -exec rm {} \;

# документация
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -d -m755 "${DOCS}"
install -v -d -m755 "${TMP_DIR}${DOCS}"

cp -vR docs/* "${DOCS}"
cp -vR docs/* "${TMP_DIR}${DOCS}"

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
