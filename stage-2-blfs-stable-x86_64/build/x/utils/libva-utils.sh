#! /bin/bash

PRGNAME="libva-utils"

### Libva-utils (VA-API utilities)
# Набор утилит для VA-API (Video Acceleration API): av1encode, avcenc,
# avcstreamoutdemo, h264encode, hevcencode и др.

# Required:    libva
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..                \
    --prefix="${XORG_PREFIX}" \
    --buildtype=release       \
    -D drm=true               \
    -D x11=true               \
    -D wayland=true || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

/usr/sbin/ldconfig

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (VA-API utilities)
#
# Libva-utils is a collection of utilities for VA-API (Video Acceleration API)
#
# Home page: https://github.com/intel/${PRGNAME}/
# Download:  https://github.com/intel/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
