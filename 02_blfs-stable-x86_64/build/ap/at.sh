#! /bin/bash

PRGNAME="at"

### at (delayed command execution)
# Обеспечивает пакетное чтение команд оболочки из стандартного ввода или файла,
# сохраняя их как задание, которое будет запланировано для отложенного
# выполнения. Пакет требуется для соответствия LSB (Linux Standards Base)

# http://www.linuxfromscratch.org/blfs/view/stable/general/at.html

# Home page: https://salsa.debian.org/debian/at
# Download:  http://ftp.debian.org/debian/pool/main/a/at/at_3.1.23.orig.tar.gz

# Required: MTA (dovecot или exim или postfix или sendmail)
# Optional: linux-pam

ROOT="/root"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}_*.tar.?z*" 2>/dev/null | \
    sort | head -n 1 | rev | cut -d . -f 4- | cut -d _ -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${PRGNAME}_${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# перед сборкой пакета должны существовать группа и пользователь atd, который
# будет запускать демон atd

! grep -qE "^atd:" /etc/group  && \
    groupadd -g 17 atd

! grep -qE "^atd:" /etc/passwd && \
    useradd -c "atd daemon"       \
            -d /dev/null          \
            -g atd                \
            -s /bin/false         \
            -u 17 atd

# создадим каталог /var/spool/cron
mkdir -pv /var/spool/cron

# исправим путь установки документации
sed -i '/docdir/s/=.*/= @docdir@/' Makefile.in

autoreconf || exit 1
./configure                     \
    --with-daemon_username=atd  \
    --with-daemon_groupname=atd \
    SENDMAIL=/usr/sbin/sendmail || exit 1

# пакет "не любит" сборку в несколько пакетов
make -j1 || exit 1
# пакет не имеет набора тестов

AT_ALLOW="/etc/at.allow"
if [ -f "${AT_ALLOW}" ]; then
    mv "${AT_ALLOW}" "${AT_ALLOW}.old"
fi

AT_DENY="/etc/at.deny"
if [ -f "${AT_DENY}" ]; then
    mv "${AT_DENY}" "${AT_DENY}.old"
fi

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
make install docdir="${DOCS}" atdocdir="${DOCS}"
make install docdir="${DOCS}" atdocdir="${DOCS}" IROOT="${TMP_DIR}"

config_file_processing "${AT_ALLOW}"
config_file_processing "${AT_DENY}"

# скрипт /etc/init.d/atd для запуска демона atd при старте системы
(
    cd /root/blfs-bootscripts || exit 1
    make install-atd
    make install-atd DESTDIR="${TMP_DIR}"
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (delayed command execution)
#
# at and batch read shell commands from standard input (or a specified file)
# storing them as a job to be scheduled for execution at a later time. It is
# required for Linux Standards Base (LSB) conformance.
#
# Home page: https://salsa.debian.org/debian/${PRGNAME}
# Download:  http://ftp.debian.org/debian/pool/main/a/${PRGNAME}/${PRGNAME}_${VERSION}.orig.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
