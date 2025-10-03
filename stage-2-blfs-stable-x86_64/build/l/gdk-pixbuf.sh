#! /bin/bash

PRGNAME="gdk-pixbuf"

### gdk-pixbuf (image library used by GTK+ v2/3)
# Библиотека, которая загружает данные изображений в различных форматах в
# буферы в памяти. Затем буферы можно масштабировать, компоновать, измененять,
# сохранять или обрабатывать.

# Required:    glib
#              libjpeg-turbo
#              libpng
#              shared-mime-info
# Recommended: python3-docutils
#              librsvg            (runtime)
#              libtiff
# Optional:    python3-gi-docgen  (для генерации документации)
#              glibavif           (runtime, для загрузки изображений AVIF)
#              libjxl             (runtime, для загрузки изображений jpeg xl)
#              webp-pixbuf-loader (runtime, для загрузки изображений webp)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# включаем загрузчики для различных форматов изображений, например BMP и XPM
#    -D others=enabled
# не позволяем meson загружать любые дополнительные зависимости, которые не
# установлены в системе
#    --wrap-mode=nofallback
meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D others=enabled   \
    --wrap-mode=nofallback || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# создаем файл /usr/lib/gdk-pixbuf-x.x/x.x.x/loaders.cache
gdk-pixbuf-query-loaders --update-cache

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (image library used by GTK+ v2/3)
#
# GdkPixbuf is a library that loads image data in various formats and stores it
# as linear buffers in memory. The buffers can then be scaled, composited,
# modified, saved, or rendered.
#
# The gdk-pixbuf library provides a number of features:
#    - GdkPixbuf structure for representing images.
#    - Image loading facilities, both synchronous and progressive.
#    - Rendering of a GdkPixbuf into various formats:
#       drawables (windows, pixmaps), GdkRGB buffers.
#    - Fast scaling and compositing of pixbufs.
#    - Simple animation loading (ie. animated gifs).
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
