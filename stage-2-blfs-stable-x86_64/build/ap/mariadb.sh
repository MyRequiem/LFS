#! /bin/bash

PRGNAME="mariadb"

### MariaDB (Drop-in replacement for the MySQL Database Server)
# Обратно совместимая ветка MySQL, разрабатываемая под лицензией GNU GPL

# Required:    cmake
# Recommended: libevent
# Optional:    boost
#              libaio
#              libxml2
#              linux-pam
#              mit-kerberos-v5
#              pcre2
#              ruby
#              unixodbc
#              valgrind
#              groonga          (https://groonga.org/)
#              kytea            (http://www.phontron.com/kytea/)
#              judy             (https://sourceforge.net/projects/judy/)
#              lz4              (https://github.com/lz4/lz4)
#              mecab            (http://taku910.github.io/mecab/)
#              messagepack      (https://msgpack.org/)
#              mruby            (https://mruby.org/)
#              python3-sphinx   (http://sphinxsearch.com/downloads/)
#              myrocks          (https://mariadb.com/kb/en/myrocks/)
#              snappy           (https://github.com/google/snappy)
#              zeromq           (https://zeromq.org/)

### Конфигурация
#    /etc/mysql/my.cnf
#    ~/.my.cnf
#
# После установки:
#    * установить базу данных и сменить владельца на непривилегированного:
#       # mysql_install_db --basedir=/usr --datadir=/srv/mysql --user=mysql
#       # chown -R mysql:mysql /srv/mysql
#
#    * запускаем сервер:
#       # install -v -m755 -o mysql -g mysql -d /run/mysqld
#       # mysqld_safe --user=mysql 2>&1 >/dev/null
#
#    * по умолчанию пароль администратора не устанавливается, поэтому установим
#       # mysqladmin -u root password
#
#    * выключить сервер
#       # mysqladmin -p shutdown

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/mysql"

# создадим группу и пользователя mysql
! grep -qE "^mysql:" /etc/group  && \
    groupadd -g 40 mysql

! grep -qE "^mysql:" /etc/passwd && \
    useradd -c "MySQL Server"       \
            -d /srv/mysql           \
            -g mysql                \
            -s /bin/false           \
            -u 40 mysql

mkdir build
cd build || exit 1

# включаем поддержку сложных наборов символов
#    -DWITH_EXTRA_CHARSETS=complex
# включаем компиляцию библиотеки для встроенного сервера, необходимой некоторым
# приложениям, например Amarok
#    -DWITH_EMBEDDED_SERVER=ON
# отключаем тесты для MariaDB Connector/C, которые не поддерживаются без
# дополнительной настройки
#    -DSKIP_TESTS=ON
cmake                                                        \
    -DCMAKE_BUILD_TYPE=Release                               \
    -DCMAKE_INSTALL_PREFIX=/usr                              \
    -DGRN_LOG_PATH=/var/log/groonga.log                      \
    -DINSTALL_DOCDIR="share/doc/${PRGNAME}-${VERSION}"       \
    -DINSTALL_DOCREADMEDIR="share/doc/${PRGNAME}-${VERSION}" \
    -DINSTALL_MANDIR=share/man                               \
    -DINSTALL_MYSQLSHAREDIR=share/mysql                      \
    -DINSTALL_MYSQLTESTDIR=share/mysql/test                  \
    -DINSTALL_PAMDIR=lib/security                            \
    -DINSTALL_PAMDATADIR=/etc/security                       \
    -DINSTALL_PLUGINDIR=lib/mysql/plugin                     \
    -DINSTALL_SBINDIR=sbin                                   \
    -DINSTALL_SCRIPTDIR=bin                                  \
    -DINSTALL_SQLBENCHDIR=share/mysql/bench                  \
    -DINSTALL_SUPPORTFILESDIR=share/mysql                    \
    -DMYSQL_DATADIR=/srv/mysql                               \
    -DMYSQL_UNIX_ADDR=/run/mysqld/mysqld.sock                \
    -DWITH_EXTRA_CHARSETS=complex                            \
    -DWITH_EMBEDDED_SERVER=ON                                \
    -DSKIP_TESTS=ON                                          \
    -DTOKUDB_OK=0                                            \
    .. || exit 1

make || exit 1

# тесты:
# make test
# более обширный набор тестов
# pushd mysql-test || exit 1
# ./mtr --parallel "$(nproc)" --mem --force
# popd || exit 1

make install DESTDIR="${TMP_DIR}"

# удалим не нужный каталог
rm -rf "${TMP_DIR}/usr/share/mysql/test"

MY_CNF="/etc/mysql/my.cnf"
cat << EOF > "${TMP_DIR}${MY_CNF}"
# Begin ${MY_CNF}

# The following options will be passed to all MySQL clients
[client]
#password       = your_password
port            = 3306
socket          = /run/mysqld/mysqld.sock

# The MySQL server
[mysqld]
port            = 3306
socket          = /run/mysqld/mysqld.sock
datadir         = /srv/mysql
skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
sort_buffer_size = 512K
net_buffer_length = 16K
myisam_sort_buffer_size = 8M

# Don't listen on a TCP/IP port at all.
skip-networking

# required unique id between 1 and 2^32 - 1
server-id       = 1

# Uncomment the following if you are using BDB tables
#bdb_cache_size = 4M
#bdb_max_lock = 10000

# InnoDB tables are now used by default
innodb_data_home_dir = /srv/mysql
innodb_log_group_home_dir = /srv/mysql
# All the innodb_xxx values below are the default ones:
innodb_data_file_path = ibdata1:12M:autoextend
# You can set .._buffer_pool_size up to 50 - 80 %
# of RAM but beware of setting memory usage too high
innodb_buffer_pool_size = 128M
innodb_log_file_size = 48M
innodb_log_buffer_size = 16M
innodb_flush_log_at_trx_commit = 1
innodb_lock_wait_timeout = 50

[mysqldump]
quick
max_allowed_packet = 16M

[mysql]
no-auto-rehash
# Remove the next comment character if you are not familiar with SQL
#safe-updates

[isamchk]
key_buffer = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqlhotcopy]
interactive-timeout

# End ${MY_CNF}
EOF

# для автозапуска mariadb при загрузке системы установим скрипт инициализации
# /etc/rc.d/init.d/mysql
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-mysql DESTDIR="${TMP_DIR}"
)

if [ -f "${MY_CNF}" ]; then
    mv "${MY_CNF}" "${MY_CNF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${MY_CNF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Drop-in replacement for the MySQL Database Server)
#
# MariaDB is a backward compatible, drop-in replacement branch of the MySQL(R)
# Database Server. It includes all major open source storage engines, including
# the Aria storage engine.
#
# Home page: http://${PRGNAME}.org/
# Download:  https://downloads.${PRGNAME}.org/interstitial/${PRGNAME}-${VERSION}/source/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
