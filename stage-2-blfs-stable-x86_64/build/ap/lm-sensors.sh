#! /bin/bash

PRGNAME="lm-sensors"

### lm-sensors (hardware monitoring package)
# Инструменты для контроля температуры ЦП, напряжения и регулировки
# производительности некоторых аппаратных средств (например, вентиляторов
# охлаждения)

# Required:    which
# Recommended: no
# Optional:    rrdtool    (для сборки sensord) https://oss.oetiker.ch/rrdtool/
#              dmidecode  https://www.nongnu.org/dmidecode/

### Конфигурация ядра
#    CONFIG_ACPI=y
#    CONFIG_ACPI_BATTERY=y|m
#    CONFIG_ACPI_THERMAL=y|m
#    CONFIG_BLK_DEV_NVME=y
#    CONFIG_NVME_HWMON=y
#    CONFIG_HWMON=y|m
#    CONFIG_SENSORS_K8TEMP=y|m
#    CONFIG_SENSORS_K10TEMP=y|m
#    CONFIG_SENSORS_FAM15H_POWER=y|m
#    CONFIG_SENSORS_CORETEMP=y|m

### Конфигурация:
#    /etc/sensors3.conf
#
# Данный конфиг изменять не следует, а все настройки для конкретных материнских
# плат делать в пользовательских конфигах /etc/sensors.d/*
#
# Определим все аппаратные датчики, которые есть в системе
#    # sensors-detect

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}-*.tar.?z*" \
    2>/dev/null | sort | head -n 1 | rev | cut -d . -f 3- | rev | \
    cut -d - -f 3-)"
VERSION="${ARCH_VERSION//-/.}"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${ARCH_VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${ARCH_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make                   \
    PREFIX=/usr        \
    BUILD_STATIC_LIB=0 \
    MANDIR=/usr/share/man || exit 1

# пакет не имеет набора тестов

make                   \
    PREFIX=/usr        \
    BUILD_STATIC_LIB=0 \
    MANDIR=/usr/share/man install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (hardware monitoring package)
#
# lm_sensors provides tools for monitoring the temperatures, voltages, and fans
# of Linux systems with hardware monitoring devices. Included are text-based
# tools for sensor reporting, and a library for sensors access called
# libsensors. It also contains tools for sensor hardware identification and I2C
# bus probing.
#
# Home page: https://github.com/hramrach/${PRGNAME}/
# Download:  https://github.com/hramrach/${PRGNAME}/archive/V${ARCH_VERSION}/${PRGNAME}-${ARCH_VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
