#! /bin/bash

PRGNAME="ntp"

### ntp (Network Time Protocol daemon)
# Служба (демон) для точной синхронизации времени через интернет. Она
# связывается с атомными часами по всему миру, чтобы время на вашем компьютере
# всегда совпадало с мировым до миллисекунды.

# Required:    perl-io-socket-ssl
# Recommended: no
# Optional:    libcap               (собранный с PAM)
#              libevent
#              libedit              (https://www.thrysoee.dk/editline/)
#              autogen              (https://www.gnu.org/software/autogen/)

# * Постоянный мониторинг: Демон регулярно (раз в несколько минут) опрашивает
#    удаленные серверы точного времени. Коррекция времени происходит с учетом
#    задержки сети.
# * Расчет дрейфа (Drift): Демон изучает особенности процессора и материнской
#    платы. Он понимает, на сколько миллисекунд в сутки спешат или отстают ваши
#    кварцевые часы, и автоматически компенсирует эту погрешность в файле
#    ntp.drift
# * Плавная подстройка (Slewing): Если ntpd обнаруживает мизерную разницу
#    (например, доли секунды), он не меняет время мгновенно. Вместо этого он
#    ускоряет или замедляет ход системных часов ядра Linux. Это защищает базы
#    данных и логи от сбоев из-за «прыжков» во времени.
# * Порог, при котором ntpd перестает плавно подкручивать часы и вместо этого
#    меняет время мгновенно (рывком), равен 128 миллисекундам. Разница от 128
#    миллисекунд до 1000 секунд (режим Stepping) демон считает слишком большим
#    для плавного выравнивания (Slewing).
# * Защита от аномалий (Panic Gate): Если время на сервере сместилось более чем
#    на 1000 секунд, ntpd посчитает это критической ошибкой и автоматически
#    завершит работу, чтобы не испортить данные.

### NOTE:
# После установки пакета можно проверить его работу
#    $ /etc/rc.d/init.d/ntpd stop
#    $ ntpd -q
#    $ /etc/rc.d/init.d/ntpd start
# Команда 'ntpd -q' запустит ntd демон, синхронизирует время и завершит работу.

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

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

# исправим проблему сборки с glibc >=2.43
sed -i 's/getclock/getclock memchr/' sntp/m4/ntp_libntp.m4 || exit 1
sed -i 's/pthread_detach(NULL)/pthread_detach(0)/' \
    sntp/m4/openldap-thread-check.m4 || exit 1

autoreconf -fiv || exit 1

# применим исправление в апстрим, для предотвращения ошибки сегментации
sed -i "/ep.*FAILED/,+4s/ep/ep2/" ntpd/ntp_io.c

# ntpd запускается от имени пользователя ntp, поэтому используем возможности
# Linux для управления системным временем без полномочий root
#    --enable-linuxcaps
# включаем поддержку Readline для утилит ntpdc и ntpq
#    --with-lineeditlibs=readline
./configure                      \
    --prefix=/usr                \
    --bindir=/usr/sbin           \
    --sysconfdir=/etc            \
    --enable-linuxcaps           \
    --with-lineeditlibs=readline \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/libexec"
rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses,man/man8}

# ntp.drift
VAR_LIB_NTP="/var/lib/ntp"
install -dm 775 -o ntp -g ntp "${TMP_DIR}${VAR_LIB_NTP}"
touch          "${TMP_DIR}${VAR_LIB_NTP}/ntp.drift"
echo "0.000" > "${TMP_DIR}${VAR_LIB_NTP}/ntp.drift"
chown ntp:ntp  "${TMP_DIR}${VAR_LIB_NTP}/ntp.drift"
chmod 644      "${TMP_DIR}${VAR_LIB_NTP}/ntp.drift"

### Конфигурация
NTP_CONF="/etc/ntp.conf"
cat << EOF > "${TMP_DIR}${NTP_CONF}"
# Start ${NTP_CONF}
#
# File to store the process ID of the running daemon
pidfile /var/run/ntpd.pid

# Log file
logfile /var/log/ntp
logconfig =syncstatus +sysevents

# File used to record the frequency offset of the system clock. Must be in a
# directory writable by the ntpd user (no symlinks allowed).
driftfile /var/lib/ntp/ntp.drift

# Default access control policy
#    - nomodify: Prevent runtime configuration changes via ntpq/ntpdc
#    - notrap:   Disable remote message logging traps
#    - nopeer:   Prevent establishing asymmetric peering relationships
#    - noquery:  Disable status queries from remote clients
#    - limited:  Deny service if the client exceeds rate limits
#    - kod:      Send a Kiss-of-Death packet when rate limit is violated
restrict    default nomodify notrap nopeer noquery limited kod
# for IPv6
restrict -6 default nomodify notrap nopeer noquery limited kod

# Permit full access from localhost for management and monitoring
restrict 127.0.0.1
restrict ::1

# Upstream NTP servers (iburst speeds up initial synchronization)
server 0.pool.ntp.org iburst
server 1.pool.ntp.org iburst
server 2.pool.ntp.org iburst
server 3.pool.ntp.org iburst

# End ${NTP_CONF}
EOF

# добавим скрипт получения разницы локального и точного временем
NTPDIFF="/usr/sbin/ntpdiff"
cat << EOF > "${TMP_DIR}${NTPDIFF}"
#!/bin/bash

ntpdate -q pool.ntp.org | /usr/bin/grep ntpdate
EOF
chmod 755 "${TMP_DIR}${NTPDIFF}"

# скрипт инициализцации при запуске системы
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-ntpd DESTDIR="${TMP_DIR}"
)

if [ -f "${NTP_CONF}" ]; then
    mv "${NTP_CONF}" "${NTP_CONF}.old"
fi

# остановим демон, если запущен
if pgrep -x ntpd &>/dev/null; then
    /etc/rc.d/init.d/ntpd stop
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${NTP_CONF}"

/etc/rc.d/init.d/ntpd start

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Network Time Protocol daemon)
#
# The ntp package contains a client and server to keep the time synchronized
# between various computers over a network.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://www.eecis.udel.edu/~${PRGNAME}/ntp_spool/${PRGNAME}4/${PRGNAME}-${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
