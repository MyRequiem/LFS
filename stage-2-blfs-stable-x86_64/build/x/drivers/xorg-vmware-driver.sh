#! /bin/bash

PRGNAME="xorg-vmware-driver"
ARCH_NAME="xf86-video-vmware"

### Xorg VMware Driver (VMWare SVGA video driver for the Xorg X server)
# Пакет драйверов для VMware и виртуальных SVGA видеокарт

# Required:    xorg-server
# Recommended: no
# Optional:    no

### Конфигурация ядра
#    CONFIG_DRM=y|m
#    CONFIG_DRM_VMWGFX=y|m
#    CONFIG_DRM_VMWGFX_FBCON=y|m

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
# Package: ${PRGNAME} (VMWare SVGA video driver for the Xorg X server)
#
# The Xorg VMware Driver package contains the X.Org Video Driver for VMware
# SVGA virtual video cards
#
# Home page: https://www.x.org/wiki/vmware/
# Download:  https://www.x.org/pub/individual/driver/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
