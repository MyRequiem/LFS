#! /bin/bash

PRGNAME="cyrus-sasl"

### Cyrus SASL (Simple Authentication and Security Layer)
# Библиотека Cyrus SASL используется почтовыми программами на клиентской или
# серверной стороне для предоставления услуг аутентификации и авторизации.

# Required:    no
# Recommended: berkeley-db
# Optional:    linux-pam
#              mit-kerberos-v5
#              mariadb или mysql (https://www.mysql.com/)
#              openjdk
#              openldap
#              postgresql
#              sqlite
#              krb4                           (https://stuff.mit.edu/afs/net.mit.edu/project/attic/krb4/)
#              dmalloc                        (https://dmalloc.com/)
#              perl-pod-pom-view-restructured (https://metacpan.org/pod/Pod::POM::View::Restructured)
#              sphinx                         (https://pypi.org/project/Sphinx/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/html"

# исправим ошибку сборки, если в системе установлен пакет sphinx или
# python-docutils
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-doc_fixes-1.patch" || exit 1

PAM="--without-pam"
MYSQL="--without-mysql"
OPENJDK="--disable-java"
OPENLDAP="--without-ldap"
POSTGRESQL="--without-pgsql"
SQLITE3="--without-sqlite3"
KRB4="--disable-krb4"
DMALLOC="--without-dmalloc"

command -v mkhomedir_helper &>/dev/null && PAM="--with-pam"
command -v mysql            &>/dev/null && MYSQL="--with-mysql"
command -v java             &>/dev/null && OPENJDK="--enable-java"
command -v ldapadd          &>/dev/null && OPENLDAP="--with-ldap"
command -v createdb         &>/dev/null && POSTGRESQL="--with-pgsql"
command -v sqlite3          &>/dev/null && SQLITE3="--with-sqlite3"
command -v krb4-config      &>/dev/null && KRB4="--enable-krb4"
command -v dmalloc          &>/dev/null && DMALLOC="--with-dmalloc"

# включает сервер аутентификации SASLDB
#    --enable-auth-sasldb
# база данных sasldb создается в /var/lib/sasl вместо /etc
#    --with-dbpath=/var/lib/sasl/sasldb2
# saslauthd использует FHS-совместимый каталог /var/run/saslauthd
#    --with-saslauthd=/var/run/saslauthd
./configure                             \
    --prefix=/usr                       \
    --sysconfdir=/etc                   \
    --enable-auth-sasldb                \
    --with-dbpath=/var/lib/sasl/sasldb2 \
    --without-sqlite                    \
    "${PAM}"                            \
    "${MYSQL}"                          \
    "${OPENJDK}"                        \
    "${OPENLDAP}"                       \
    "${POSTGRESQL}"                     \
    "${SQLITE3}"                        \
    "${KRB4}"                           \
    "${DMALLOC}"                        \
    --with-saslauthd=/var/run/saslauthd || exit 1

# пакет не поддерживаем сборку в несколько потоков, поэтому явно указываем -j1
make -j1 || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

# документация
install -v -m644  saslauthd/LDAP_SASLAUTHD "${TMP_DIR}${DOCS}"
install -v -m644  doc/legacy/*.html "${TMP_DIR}${DOCS}/html"

install -v -dm700 "${TMP_DIR}/var/lib/sasl"

# init script: /etc/rc.d/init.d/saslauthd
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-saslauthd DESTDIR="${TMP_DIR}"
)

SASLAUTHD="/etc/sysconfig/saslauthd"
if [ -f "${SASLAUTHD}" ]; then
    mv "${SASLAUTHD}" "${SASLAUTHD}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${SASLAUTHD}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simple Authentication and Security Layer)
#
# This is the Cyrus SASL library. Cyrus SASL is used by mail programs on the
# client or server side to provide authentication and authorization services.
#
# Home page: https://github.com/cyrusimap/${PRGNAME}/
# Download:  https://github.com/cyrusimap/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
