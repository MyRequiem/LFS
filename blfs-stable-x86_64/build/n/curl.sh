#! /bin/bash

PRGNAME="curl"

### cURL (command line URL data transfer tool)
# Утилита командной строки, позволяющая взаимодействовать с множеством
# различных серверов по множеству различных протоколов: FTP, FTPS, HTTP, HTTPS,
# SCP, SFTP, TFTP, TELNET, DICT, LDAP, LDAPS, FILE

# http://www.linuxfromscratch.org/blfs/view/stable/basicnet/curl.html

# Home page: https://curl.haxx.se/
# Download:  https://curl.haxx.se/download/curl-7.68.0.tar.xz

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
#              libmetalink (https://launchpad.net/libmetalink/)
#              librtmp     (http://rtmpdump.mplayerhq.hu/)
#              spnego      (http://spnego.sourceforge.net/)
#              stunnel (для HTTPS and FTPS тестов)
#              valgrind

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

C_ARES="--disable-ares"
[ -x /usr/lib/libcares.so ] && C_ARES="--enable-ares"
GNUTLS="--without-gnutls"
if command -v gnutls-cli &>/dev/null; then
    GNUTLS="--with-gnutls=/usr"
fi
LIBIDN2="--without-libidn2"
[ -x /usr/lib/libidn2.so ] && LIBIDN2="--with-libidn2=/usr"
LIBPSL="--without-libpsl"
[ -x /usr/lib/libpsl.so ] && LIBPSL="--with-libpsl"
LIBSSH2="--without-libssh2"
[ -x /usr/lib/libssh2.so ] && LIBSSH2="--with-libssh2"
NGHTTP2="--without-nghttp2"
[ -x /usr/lib/libnghttp2.so ] && NGHTTP2="--with-nghttp2=/usr"
OPENLDAP="--disable-ldap"
if command -v ldapadd &>/dev/null; then
    OPENLDAP="--enable-ldap"
fi
SAMBA="--disable-smb"
if command -v samba &>/dev/null; then
    SAMBA="--enable-smb"
fi
LIBMETALINK="--without-libmetalink"
[ -x /usr/lib/libmetalink.so ] && LIBMETALINK="--with-libmetalink=/usr"
LIBRTMP="--without-librtmp"
if command -v rtmpdump &>/dev/null; then
    LIBRTMP="--with-librtmp=/usr"
fi

./configure                    \
    --prefix=/usr              \
    --disable-static           \
    --enable-threaded-resolver \
    "${C_ARES}"                \
    "${GNUTLS}"                \
    "${LIBIDN2}"               \
    "${LIBPSL}"                \
    "${LIBSSH2}"               \
    "${NGHTTP2}"               \
    "${OPENLDAP}"              \
    "${SAMBA}"                 \
    "${LIBMETALINK}"           \
    "${LIBRTMP}"               \
    --with-ca-path=/etc/ssl/certs || exit 1

make || exit 1
# известно, что в LFS системе тесты 323, 1139, 1140, 1173 и 1560 не проходят
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
