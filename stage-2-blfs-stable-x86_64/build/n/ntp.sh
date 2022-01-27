#! /bin/bash

PRGNAME="ntp"

### ntp (Network Time Protocol daemon)
# Клиент и сервер для синхронизации времени между различными компьютерами по
# сети

# Required:    perl-io-socket-ssl
# Recommended: no
# Optional:    libcap
#              libevent
#              libedit (https://www.thrysoee.dk/editline/)
#              autogen (https://www.gnu.org/software/autogen/)

### NOTE:
# После установки пакета можно проверить его работу
#    # ntpd -q
# Команда запустит ntd демон, синхронизирует время и завершит работу. Данную
# команду можно записать в cron для автоматизации синхронизации.

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

# добавим группу ntp, если не существует
! grep -qE "^ntp:" /etc/group  && \
    groupadd -g 87 ntp

# добавим пользователя ntp, если не существует
! grep -qE "^ntp:" /etc/passwd &&      \
    useradd -c "Network Time Protocol" \
            -d /var/lib/ntp            \
            -g ntp                     \
            -s /bin/false              \
            -u 87 ntp

# исправим команду update-leap для правильной работы
sed -e 's/"(\\S+)"/"?([^\\s"]+)"?/' \
    -i scripts/update-leap/update-leap.in || exit 1

# переменная среды необходима для создания Position Independent Code, который
# используется в библиотеках пакетов
#    CFLAGS="-O2 -g -fPIC"
# ntpd запускается от имени пользователя ntp, поэтому используем возможности
# Linux для управления системным временем без полномочий root
#    --enable-linuxcaps
# включаем поддержку Readline для утилит ntpdc и ntpq
#    --with-lineeditlibs=readline
./configure                                  \
    CFLAGS="-O2 -g -fPIC -fcommon ${CFLAGS}" \
    --prefix=/usr                            \
    --bindir=/usr/sbin                       \
    --sysconfdir=/etc                        \
    --enable-linuxcaps                       \
    --with-lineeditlibs=readline             \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${DOCS}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/doc"

install -v -o ntp -g ntp -d "${TMP_DIR}/var/lib/ntp/"

# init script: /etc/rc.d/init.d/ntp
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-ntpd DESTDIR="${TMP_DIR}"
)

### Конфигурация
NTP_CONF="/etc/ntp.conf"
cat << EOF > "${TMP_DIR}${NTP_CONF}"
# Start ${NTP_CONF}

### NTP server (list one or more) to synchronize with
# server 0.pool.ntp.org
# server 1.pool.ntp.org
# server 2.pool.ntp.org
# server 3.pool.ntp.org
# server time1.google.com
# server time2.google.com
# server time3.google.com
# server time4.google.com

# Europe
server 0.europe.pool.ntp.org

# Asia
server 0.asia.pool.ntp.org

# Australia
server 0.oceania.pool.ntp.org

# North America
server 0.north-america.pool.ntp.org

# South America
server 2.south-america.pool.ntp.org

### Drift file
# Put this in a directory which the daemon can write to. No symbolic links
# allowed, either, since the daemon updates the file by creating a temporary in
# the same directory and then rename()'ing it to the file
driftfile /var/lib/ntp/ntp.drift

pidfile   /var/run/ntpd.pid
leapfile  /var/lib/ntp/ntp.leapseconds

# Security session
# don't serve time or stats to anyone else by default (more secure)
restrict    default limited kod nomodify notrap nopeer noquery
restrict -6 default limited kod nomodify notrap nopeer noquery

# Trust ourselves.  :-)
restrict 127.0.0.1
restrict ::1

# End ${NTP_CONF}
EOF

if [ -f "${NTP_CONF}" ]; then
    mv "${NTP_CONF}" "${NTP_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${NTP_CONF}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Network Time Protocol daemon)
#
# The ntp package contains a client and server to keep the time synchronized
# between various computers over a network.
#
# Home page: http://www.${PRGNAME}.org/
# Download:  https://www.eecis.udel.edu/~${PRGNAME}/ntp_spool/${PRGNAME}4/${PRGNAME}-${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
