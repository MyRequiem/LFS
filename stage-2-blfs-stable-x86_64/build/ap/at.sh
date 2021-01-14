#! /bin/bash

PRGNAME="at"

### at (delayed command execution)
# Обеспечивает пакетное чтение команд оболочки из стандартного ввода или файла,
# сохраняя их как задание, которое будет запланировано для отложенного
# выполнения. Пакет требуется для соответствия LSB (Linux Standards Base)

# Required:    MTA (dovecot или exim или postfix или sendmail)
# Recommended: no
# Optional:    linux-pam

ROOT="/root/src/lfs"
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
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

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

./configure \
    --with-daemon_username=atd        \
    --with-daemon_groupname=atd       \
    --with-jobdir=/var/spool/atjobs   \
    --with-atspool=/var/spool/atspool \
    SENDMAIL=/usr/sbin/sendmail || exit 1

# пакет "не любит" сборку в несколько потоков
make -j1 || exit 1
# пакет не имеет набора тестов
make install docdir="${DOCS}" atdocdir="${DOCS}" IROOT="${TMP_DIR}"

# скрипт /etc/init.d/atd для запуска демона atd при старте системы
(
    cd /root/src/lfs/blfs-bootscripts || exit 1
    make install-atd DESTDIR="${TMP_DIR}"
)

AT_ALLOW="/etc/at.allow"
if [ -f "${AT_ALLOW}" ]; then
    mv "${AT_ALLOW}" "${AT_ALLOW}.old"
fi

AT_DENY="/etc/at.deny"
if [ -f "${AT_DENY}" ]; then
    mv "${AT_DENY}" "${AT_DENY}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${AT_ALLOW}"
config_file_processing "${AT_DENY}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (delayed command execution)
#
# at and batch read shell commands from standard input (or a specified file)
# storing them as a job to be scheduled for execution at a later time. It is
# required for Linux Standards Base (LSB) conformance.
#
# Home page: https://salsa.debian.org/debian/${PRGNAME}
# Download:  http://software.calhariz.com/${PRGNAME}/${PRGNAME}_${VERSION}.orig.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
