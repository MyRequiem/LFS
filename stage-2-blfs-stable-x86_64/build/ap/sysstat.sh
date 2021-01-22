#! /bin/bash

PRGNAME="sysstat"

### Sysstat (System performance monitoring tools)
# Утилиты для мониторинга производительности системы и активности использования
# OS Linux. Sysstat содержит служебную программу 'sar', общую для многих
# коммерческих дистрибутивов Linux и инструменты (iostat, mpstat, pidstat,
# sadf, tapestat, cifsiostat), выполнение которых обычно планируется через cron
# для сбора данных.

# Required:    no
# Recommended: no
# Optional:    no

# Конфигурация
#    /etc/sysconfig/sysstat
#    /etc/sysconfig/sysstat.ioconf
#
# Примеры сбора информации истории Sysstat по расписанию с помощью fcron
# (см. $ man sa1 и $ man sa2)
#
# 8am-7pm activity reports every 10 minutes during weekdays
# 0 8-18 * * 1-5 /usr/lib/sa/sa1 600 6 &

# 7pm-8am activity reports every hour during weekdays
# 0 19-7 * * 1-5 /usr/lib/sa/sa1 &

# activity reports every hour on Saturday and Sunday
# 0 * * * 0,6 /usr/lib/sa/sa1 &

# daily summary prepared at 19:05
# 5 19 * * * /usr/lib/sa/sa2 -A &

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# устанавливаем права root:root для man-страниц
#    --disable-file-attr
sa_lib_dir=/usr/lib/sa  \
sa_dir=/var/log/sa      \
conf_dir=/etc/sysconfig \
./configure             \
    --prefix=/usr       \
    --disable-file-attr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# man страницы запакованы в *.xz, распакуем их
find "${TMP_DIR}/usr/share/man/" -type f -name "*.xz" -exec unxz {} \;

# автозапуск очистки счетчиков ядра для sysstat при запуске системы
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-sysstat DESTDIR="${TMP_DIR}"
)

SYSSTAT="/etc/sysconfig/sysstat"
SYSSTAT_IOCONF="/etc/sysconfig/sysstat.ioconf"

if [ -f "${SYSSTAT}" ]; then
    mv "${SYSSTAT}" "${SYSSTAT}.old"
fi

if [ -f "${SYSSTAT_IOCONF}" ]; then
    mv "${SYSSTAT_IOCONF}" "${SYSSTAT_IOCONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${SYSSTAT}"
config_file_processing "${SYSSTAT_IOCONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (System performance monitoring tools)
#
# The Sysstat package contains utilities to monitor system performance and
# usage activity for Linux. Sysstat contains the 'sar' utility, common to many
# commercial Unixes, and tools you can schedule via cron to collect and
# historize performance and activity data (iostat, mpstat, pidstat, sadf,
# tapestat, cifsiostat).
#
# Home page: http://pagesperso-orange.fr/sebastien.godard/
# Download:  http://sebastien.godard.pagesperso-orange.fr/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
