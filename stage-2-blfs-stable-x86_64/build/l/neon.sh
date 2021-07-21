#! /bin/bash

PRGNAME="neon"

### neon (HTTP and WebDAV client library)
# HTTP и WebDAV клиентская библиотека с С-интерфейсом. Используется такими
# проектами, как Subversion.

# Required:    no
# Recommended: no
# Optional:    gnutls
#              libxml2
#              mit-kerberos-v5
#              libproxy (https://github.com/libproxy/libproxy)
#              pakchois (http://www.manyfish.co.uk/pakchois/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# включаем поддержку SSL с использованием OpenSSL или GnuTLS соответственно
#    --with-ssl
# Чтобы принудительно использовать GnuTLS, передаем такие параметры:
#    --with-ssl=gnutls and --with-ca-bundle=/etc/pki/tls/certs/ca-bundle.crt
./configure          \
    --prefix=/usr    \
    --with-ssl       \
    --enable-shared  \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (HTTP and WebDAV client library)
#
# neon is an HTTP and WebDAV client library, with a C language API. The neon
# library is used by projects such as subversion.
#
# Home page: https://notroj.github.io/${PRGNAME}/
# Download:  https://notroj.github.io/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
