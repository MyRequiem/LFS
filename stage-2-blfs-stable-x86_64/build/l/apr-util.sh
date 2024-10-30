#! /bin/bash

PRGNAME="apr-util"

### Apr-Util (Apache Portable Runtime utilities)
# Пакет содержит дополнительные служебные интерфейсы для APR включая поддержку
# XML, LDAP, интерфейсов базы данных, парсинга URI, и т.д.

# Required:    apr
# Recommended: no
# Optional:    berkeley-db
#              freetds          (https://www.freetds.org/)
#              mariadb or mysql (https://www.mysql.com/)
#              openldap
#              postgresql
#              sqlite
#              unixodbc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# включает плагин apr_dbm_gdbm-1.so
#    --with-gdbm=/usr
# включают плагин apr_crypto_openssl-1.so и поддержку криптографии
#    --with-openssl=/usr
#    --with-crypto
# включает плагин apr_ldap.so
#    --with-ldap
# включает плагин apr_dbm_db-1.so
#    --with-berkeley-db=/usr

./configure             \
    --prefix=/usr       \
    --with-apr=/usr     \
    --with-gdbm=/usr    \
    --with-openssl=/usr \
    --with-crypto       \
    --with-ldap         \
    --with-berkeley-db=/usr || exit 1

make || exit 1
# make -j1 test
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
