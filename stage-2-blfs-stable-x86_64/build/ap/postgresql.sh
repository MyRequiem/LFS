#! /bin/bash

PRGNAME="postgresql"

### PostgreSQL (object-relational database management system)
# Свободная объектно-реляционная СУБД (система управления базами данных) на
# основе POSTGRES и Berkeley Postgres

# Required:    no
# Recommended: no
# Optional:    python2
#              icu
#              libxml2
#              libxslt
#              openldap
#              linux-pam
#              mit-kerberos-v5
#              bonjour (https://developer.apple.com/bonjour/)
#              fop
#              docbook4.5
#              docbook-dsssl
#              docbook-utils
#              openjade
#              perl-sgmlspm

### Конфигурация
#    /usr/share/${PRGNAME}-${VERSION}/pg_ident.conf
#    /usr/share/${PRGNAME}-${VERSION}/pg_hba.conf
#    /usr/share/${PRGNAME}-${VERSION}/postgresql.conf

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# создадим группу и пользователя postgres
! grep -qE "^postgres:" /etc/group  && \
    groupadd -g 41 postgres

! grep -qE "^postgres:" /etc/passwd && \
    useradd -c "PostgreSQL Server"     \
            -g postgres                \
            -d /srv/pgsql/data         \
            -u 41 postgres

# изменим расположение сокета сервера с /tmp на /run/postgresql
sed -i '/DEFAULT_PGSOCKET_DIR/s@/tmp@/run/postgresql@' \
    src/include/pg_config_manual.h || exit 1

./configure                                      \
    --prefix=/usr                                \
    --enable-thread-safety                       \
    --with-system-tzdata=/usr/share/zoneinfo     \
    --with-openssl                               \
    --with-tcl                                   \
    --with-perl                                  \
    --with-python                                \
    --with-libxml                                \
    --with-libxslt                               \
    --sysconfdir="/etc/${PRGNAME}/${VERSION}"    \
    --datadir="/usr/share/${PRGNAME}-${VERSION}" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# собираем дополнительные серверные утилиты из каталога contrib
make -C contrib

# тесты необходимо запускать от имени непривилегированного пользователя, потому
# что им нужно запустить временный сервер. По той же причине необходимо
# остановить все серверы PostgreSQL, если они работают
# make check

make install            DESTDIR="${TMP_DIR}"
make install-docs       DESTDIR="${TMP_DIR}"
make -C contrib install DESTDIR="${TMP_DIR}"

install -v -dm700 "${TMP_DIR}/srv/pgsql/data"
chown -Rv postgres:postgres "${TMP_DIR}/srv/pgsql"

# для автозапуска PostgreSQL при загрузке системы установим скрипт
# инициализации /etc/rc.d/init.d/postgresql
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-postgresql DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (object-relational database management system)
#
# PostgreSQL is an advanced object-relational database management system
# (ORDBMS) based on POSTGRES and derived from the Berkeley Postgres database
# management system. With more than 15 years of development history, it is
# quickly becoming the de facto database for enterprise level open source
# solutions.
#
# Home page: https://www.${PRGNAME}.org
# Download:  http://ftp.${PRGNAME}.org/pub/source/v${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
