#! /bin/bash

PRGNAME="apr-util"

### Apr-Util (Apache Portable Runtime utilities)
# Пакет содержит дополнительные служебные интерфейсы для APR включая поддержку
# XML, LDAP, интерфейсов базы данных, парсинга URI, и т.д.

# http://www.linuxfromscratch.org/blfs/view/stable/general/apr-util.html

# Home page: https://apr.apache.org/
# Download:  https://archive.apache.org/dist/apr/apr-util-1.6.1.tar.bz2

# Required: apr
# Optional: berkeley-db
#           freetds (http://www.freetds.org/)
#           mariadb or mysql (https://www.mysql.com/)
#           openldap
#           postgresql
#           sqlite
#           unixodbc

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# включает плагин apr_dbm_gdbm-1.so
#    --with-gdbm=/usr
# включают плагин apr_crypto_openssl-1.so
#    --with-openssl=/usr
#    --with-crypto
./configure             \
    --prefix=/usr       \
    --with-apr=/usr     \
    --with-gdbm=/usr    \
    --with-openssl=/usr \
    --with-crypto || exit 1

make || exit 1
# make test
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Apache Portable Runtime utilities)
#
# This package contains additional utility interfaces for APR (Apache Portable
# Runtime) including support for XML, LDAP, database interfaces, URI parsing,
# and more.
#
# Home page: https://apr.apache.org/
# Download:  https://archive.apache.org/dist/apr/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
