#! /bin/bash

PRGNAME="xorg-amdgpu-driver"
ARCH_NAME="xf86-video-amdgpu"

### Xorg AMDGPU Driver (video driver for newer AMD Radeon video cards)
# Видеодрайвер X.Org для относительно новых (начиная с Volcanic Islands)
# видеокарт AMD Radeon

# Required:    xorg-server
# Recommended: no
# Optional:    no

### NOTE:
# Для работы Direct Rendering необходимо включить драйвер radeonsi Gallium во
# время сборки Mesa
#    GALLIUM_DRV="[...,]radeonsi[,...]"
# Кроме того, для всех карт требуется прошивка (firmware), которую можно
# получить по адресу
#    http://anduin.linuxfromscratch.org/BLFS/linux-firmware/

### Конфигурация ядра
#    CONFIG_DRM=y
#    CONFIG_DRM_AMDGPU=y|m
#    CONFIG_DRM_AMDGPU_SI=y
#    CONFIG_DRM_AMDGPU_CIK=y
#
# Если для видеокарты нужны дополнительные прошивки (firmware), то после их
# установки в /lib/firmware указываем на них в конфиге ядра:
#    CONFIG_EXTRA_FIRMWARE="amdgpu/topaz_ce.bin amdgpu/topaz_k_smc.bin ..."

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/xorg_config.sh"                          || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure \
    ${XORG_CONFIG} || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (video driver for newer AMD Radeon video cards)
#
# The Xorg AMDGPU Driver package contains the X.Org Video Driver for newer AMD
# Radeon video cards starting from Volcanic Islands. It can also be used for
# Southern and Sea Islands if the experimental support was enabled in the
# kernel.
#
# Home page: https://cgit.freedesktop.org/xorg/driver/${ARCH_NAME}/
# Download:  https://www.x.org/pub/individual/driver/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
