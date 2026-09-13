#! /bin/bash

PRGNAME="curl"

### cURL (command line URL data transfer tool)
# Универсальный инструмент и библиотека для передачи данных между серверами,
# поддерживающий почти все современные протоколы.

# Required:    no
# Recommended: libpsl
#              nghttp2              (требуется для использования системного cURL в Rustc)
#              make-ca              (runtime)
# Optional:    brotli
#              c-ares
#              gnutls
#              libidn2
#              libssh2
#              mit-kerberos-v5
#              openldap
#              samba
#              gsasl                (https://www.gnu.org/software/gsasl/)
#              impacket             (https://www.secureauth.com/labs/open-source-tools/impacket)
#              libmetalink          (https://launchpad.net/libmetalink/)
#              librtmp              (http://rtmpdump.mplayerhq.hu/)
#              ngtcp2               (https://github.com/ngtcp2/ngtcp2/)
#              quiche               (https://github.com/cloudflare/quiche)
#              spnego               (http://spnego.sourceforge.net/)
#              --- для тестов ---
#              apache-httpd
#              stunnel              (для HTTPS and FTPS тестов)
#              openssh
#              valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --with-openssl   \
    --with-ca-path=/etc/ssl/certs || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command line URL data transfer tool)
#
# Curl is a command line tool for transferring data specified with URL syntax.
# The command is designed to work without user interaction or any kind of
# interactivity. Curl offers a busload of useful tricks like proxy support,
# user authentication, ftp upload, HTTP post, SSL (https:) connections,
# cookies, file transfer resume and more.
#
# Home page: https://${PRGNAME}.se/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${PRGNAME}-${VERSION//./_}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
