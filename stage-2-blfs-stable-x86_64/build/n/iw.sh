#! /bin/bash

PRGNAME="iw"

### iw (tool for configuring Linux wireless devices)
# Утилита для настройки беспроводных устройств на основе nl80211 и mac80211 с
# интерфейсом командной строки. Поддерживает все новые драйверы, недавно
# добавленные в ядро. Старый инструмент iwconfig, использующий интерфейс
# Wireless Extensions, устарел и настоятельно рекомендуется перейти на iw

# Required:    libnl
# Recommended: no
# Optional:    no

###
# Конфигурация ядра
###
#    CONFIG_PCCARD=m
#    CONFIG_YENTA=m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# устанавливаем не сжатые man-страницы
sed -i "/INSTALL.*gz/s/.gz//" Makefile || exit 1

make || exit 1
# пакет не имеет набора тестов
make SBINDIR=/usr/sbin install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tool for configuring Linux wireless devices)
#
# iw is a new nl80211 based CLI configuration utility for wireless devices. It
# supports all new drivers that have been added to the kernel recently. The old
# tool iwconfig, which uses Wireless Extensions interface, is deprecated and
# it's strongly recommended to switch to iw and nl80211
#
# Home page: https://wireless.wiki.kernel.org/en/users/documentation/${PRGNAME}
# Download:  https://www.kernel.org/pub/software/network/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
