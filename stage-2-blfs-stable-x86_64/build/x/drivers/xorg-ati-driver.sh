#! /bin/bash

PRGNAME="xorg-ati-driver"
ARCH_NAME="xf86-video-ati"

### Xorg ATI Driver (Video Driver for ATI Radeon video cards)
# Видео драйвер X.Org для видеокарт ATI Radeon, включая все чипсеты от R100 до
# Volcanic Islands

# Required:    xorg-server
# Recommended: no
# Optional:    no

### NOTE:
# Для работы Direct Rendering необходимо включить драйвера r300, r600 и
# radeonsi Gallium во время сборки Mesa
#    GALLIUM_DRV="[...,] r300,r600,radeonsi[,...]"
# Кроме того, некоторые карты требуют прошивки (firmware), которые можно
# получить по адресу
#    http://anduin.linuxfromscratch.org/BLFS/linux-firmware/

### Конфигурация ядра
#    CONFIG_DRM=y
#    CONFIG_DRM_RADEON=y|m
#
# Если для видеокарты нужны дополнительные прошивки (firmware), то после их
# установки в /lib/firmware указываем на них в конфиге ядра:
#    CONFIG_EXTRA_FIRMWARE="radeon/BTC_rlc.bin radeon/CAICOS_mc.bin ..."

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/xorg_config.sh"                          || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# адаптируем drmmode_display.h к изменениям в GCC-10
sed -e 's/miPointer/extern &/' -i src/drmmode_display.h

GLAMOR="--disable-glamor"
[ -x /usr/lib/xorg/modules/libglamoregl.so ] && GLAMOR="--enable-glamor"

# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} \
    "${GLAMOR}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Video Driver for ATI Radeon video cards)
#
# The Xorg ATI Driver package contains the X.Org Video Driver for ATI Radeon
# video cards including all chipsets ranging from R100 to the "Volcanic
# Islands" chipsets.
#
# Home page: https://cgit.freedesktop.org/xorg/driver/${ARCH_NAME}
# Download:  https://www.x.org/pub/individual/driver/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
