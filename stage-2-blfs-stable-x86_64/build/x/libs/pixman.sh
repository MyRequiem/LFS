#! /bin/bash

PRGNAME="pixman"

### Pixman (pixel manipulation library)
# Библиотека содержит низкоуровневые процедуры обработки пикселей такие как
# компоновка изображений и трапецеидальная растеризация. Используется как xorg,
# так и cairo.

# Required:    no
# Recommended: no
# Optional:    --- для тестов и демо ---
#              libpng
#              gtk+2  (https://download.gnome.org/sources/gtk+/2.24/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup       \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (pixel manipulation library)
#
# The Pixman package contains a library that provides low-level pixel
# manipulation features such as image compositing and trapezoid rasterization.
# It's used by both xorg and cairo.
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://www.cairographics.org/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
