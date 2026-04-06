#! /bin/bash

PRGNAME="iw"

### iw (tool for configuring Linux wireless devices)
# Современная утилита для настройки параметров беспроводных сетей, пришедшая на
# смену старым wireless-tools.

# Required:    libnl
# Recommended: no
# Optional:    no

###
# Конфигурация ядра
###
#    CONFIG_NET=y
#    CONFIG_WIRELESS=y
#    CONFIG_CFG80211=y|m
#    CONFIG_MAC80211=y|m
#    CONFIG_NETDEVICES=y
#    CONFIG_WLAN=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# устанавливаем не сжатые man-страницы
sed -i "/INSTALL.*gz/s/.gz//" Makefile || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

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
