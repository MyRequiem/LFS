#! /bin/bash

PRGNAME="cairo"

### Cairo (graphics library used by GTK+)
# Специальный «движок» для векторного рисования, который позволяет программам
# создавать качественную 2D-графику (линии, текст, фигуры). Делает картинку
# четкой и красивой на любом устройстве: хоть на экране монитора, хоть при
# печати на бумаге или сохранении в PDF.

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
#              gtk+2            (https://download.gnome.org/sources/gtk+/2.24/)
#              libspectre       (https://www.freedesktop.org/wiki/Software/libspectre/)

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
