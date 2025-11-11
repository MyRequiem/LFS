#! /bin/bash

PRGNAME="cairo"

### Cairo (graphics library used by GTK+)
# Библиотека для отрисовки векторной графики с открытым исходным кодом.
# Включает в себя аппаратно-независимый прикладной программный интерфейс для
# разработчиков программного обеспечения. Cairo предоставляет графические
# примитивы для отрисовки двумерных изображений посредством разнообразных
# бекендов. Когда есть возможность, Cairo использует аппаратное ускорение.

# Required:    libpng
#              pixman
# Recommended: fontconfig
#              glib
#              xorg-libraries
# Optional:    ghostscript
#              gtk-doc
#              libdrm
#              librsvg
#              libxml2
#              lzo
#              poppler
#              valgrind
#              gtk+2       (https://download.gnome.org/sources/gtk+/2.24/)
#              libspectre  (https://www.freedesktop.org/wiki/Software/libspectre/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (graphics library used by GTK+)
#
# Cairo is a vector graphics library designed to provide high-quality display
# and print output. Cairo is designed to produce identical output on all output
# media while taking advantage of display hardware acceleration when available
# (eg. through the X Render Extension or OpenGL).
#
# Home page: https://www.cairographics.org/
# Download:  https://www.cairographics.org/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
