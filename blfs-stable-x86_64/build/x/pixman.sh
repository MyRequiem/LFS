#! /bin/bash

PRGNAME="pixman"

### Pixman (pixel manipulation library)
# Библиотека содержит низкоуровневые процедуры обработки пикселей такие как
# компоновка изображений и трапецеидальная растеризация. Используется как xorg,
# так и cairo.

# http://www.linuxfromscratch.org/blfs/view/stable/general/pixman.html

# Home page: http://www.pixman.org/
# Download:  https://www.cairographics.org/releases/pixman-0.38.4.tar.gz

# Required: no
# Optional: gtk+2
#           libpng (для тестов и демо)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson \
    --prefix=/usr || exit 1

ninja || exit 1

# ninja test

ninja install
DESTDIR="${TMP_DIR}" ninja install

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (pixel manipulation library)
#
# The Pixman package contains a library that provides low-level pixel
# manipulation features such as image compositing and trapezoid rasterization.
# It's used by both xorg and cairo.
#
# Home page: http://www.pixman.org/
# Download:  https://www.cairographics.org/releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
