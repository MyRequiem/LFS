#! /bin/bash

PRGNAME="xorg-nouveau-driver"
ARCH_NAME="xf86-video-nouveau"

### Xorg Nouveau Driver (accelerated open source driver for nVidia cards)
# Видеодрайвер X.Org для видеокарт NVidia, включая RIVA TNT, RIVA TNT2, GeForce
# 256, QUADRO, GeForce2, QUADRO2, GeForce3, QUADRO DDC, nForce, nForce2,
# GeForce4, QUADRO4, GeForce FX, QUADRO Чипсеты FX, GeForce 6XXX и GeForce 7xxx

# Required:    xorg-server
# Recommended: no
# Optional:    no

### Конфигурация ядра
#    CONFIG_DRM=y
#    CONFIG_DRM_NOUVEAU=y|m
#    CONFIG_DRM_NOUVEAU_BACKLIGHT=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/xorg_config.sh"                          || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправления для сборки с последней версией xorg-server
grep -rl slave | xargs sed -i s/slave/secondary/ || exit 1

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
# Package: ${PRGNAME} (accelerated open source driver for nVidia cards)
#
# The Xorg Nouveau Driver package contains the X.Org Video Driver for NVidia
# Cards including RIVA TNT, RIVA TNT2, GeForce 256, QUADRO, GeForce2, QUADRO2,
# GeForce3, QUADRO DDC, nForce, nForce2, GeForce4, QUADRO4, GeForce FX, QUADRO
# FX, GeForce 6XXX and GeForce 7xxx chipsets.
#
# Home page: https://nouveau.freedesktop.org/
# Download:  https://www.x.org/pub/individual/driver/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
