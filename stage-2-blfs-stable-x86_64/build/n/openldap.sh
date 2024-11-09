#! /bin/bash

PRGNAME="openldap"

### OpenLDAP (Lightweight Directory Access Protocol)
# Протокол прикладного уровня для доступа к службе каталогов X.500,
# разработанный как облегчённый вариант протокола DAP. Использует TCP/IP и
# позволяет производить операции аутентификации, поиска, сравнения, добавления,
# изменения или удаления записей. LDAP часто используется для обеспечения
# аутентификации (например, для электронной почты)

# Required:    no
# Recommended: cyrus-sasl
# Optional:    gnutls
#              unixodbc
#              mariadb или postgresql или mysql (http://www.mysql.com/)
#              openslp                          (http://www.openslp.org/)
#              wiredtiger                       (https://www.mongodb.com/docs/manual/core/wiredtiger/)
#              berkeley-db (для сборки slapd, но эта утилита устарела)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

### NOTE:
# собираем ТОЛЬКО клиентскую сторону и библиотеки

patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-consolidated-1.patch" || exit 1

autoconf || exit 1
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  \
    --enable-dynamic  \
    --disable-debug   \
    --disable-slapd   \
    --enable-versioning=yes || exit 1

make depend || exit 1
make        || exit 1
# при сборке только клиента и библиотек тесты не доступны
make install DESTDIR="${TMP_DIR}"

LDAP_CONF="/etc/openldap/ldap.conf"
if [ -f "${LDAP_CONF}" ]; then
    mv "${LDAP_CONF}" "${LDAP_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${LDAP_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Lightweight Directory Access Protocol)
#
# OpenLDAP is an open source implementation of the Lightweight Directory Access
# Protocol. LDAP is a alternative to the X.500 Directory Access Protocol (DAP).
# It uses the TCP/IP stack versus the overly complex OSI stack. LDAP is often
# used to provide authentication (such as for email)
#
# Home page: http://www.${PRGNAME}.org/
# Download:  https://www.${PRGNAME}.org/software/download/OpenLDAP/${PRGNAME}-release/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
