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
# Recommended: librsvg
#              libtiff
# Optional:    gobject-introspection (требуется для сборки GNOME)
#              gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

GTK_DOC="false"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="true"

meson                      \
    --prefix=/usr          \
    -Dgtk_doc="${GTK_DOC}" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# создаем файл /usr/lib/gdk-pixbuf-x.x/x.x.x/loaders.cache
gdk-pixbuf-query-loaders --update-cache

# копируем созданный loaders.cache в ${TMP_DIR}
# в loaders.cache указана директория:
#    # LoaderDir = /usr/lib/gdk-pixbuf-x.x/x.x.x/loaders
# извлечем путь /usr/lib/gdk-pixbuf-x.x/x.x.x
LOADERS_CACHE_DIR="$(dirname "$(grep LoaderDir "$(find /usr/lib/${PRGNAME}* \
    -type f -name loaders.cache)" | awk '{ print $4 }')")"
cp "${LOADERS_CACHE_DIR}/loaders.cache" "${TMP_DIR}${LOADERS_CACHE_DIR}"

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
