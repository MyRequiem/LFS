#! /bin/bash

PRGNAME="gdk-pixbuf"

### gdk-pixbuf (image library used by GTK+ v2/3)
# Библиотека для загрузки изображений и управления ими (манипуляции с
# пикселями, изменение размера), которая используется в интерфейсах на базе
# GTK. Она превращает файлы разных форматов (PNG, JPEG, TIFF) в понятные
# программе объекты в памяти.

# Required:    glib
#              shared-mime-info
# Recommended: python3-docutils
#              glycin               (циклическая зависимость: сначала собираем
#                                       без glycin, потом пересобираем уже с
#                                       установленным glycin)
# Optional:    python3-gi-docgen    (для генерации документации)
#              libavif              (runtime, deprecated)
#              libjpeg-turbo        (deprecated)
#              libjxl               (runtime, deprecated)
#              libpng               (deprecated)
#              librsvg              (runtime, deprecated)
#              libtiff              (deprecated)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/lib/gdk-pixbuf-2.0/2.10.0"

GLYCIN="disabled"
pkgconf glycin-2 &>/dev/null && GLYCIN="enabled"

mkdir build
cd build || exit 1

# Не создаем компоненты, которые устарели и заменены на glycin. Эти компоненты
# автоматически отключаются при сборке этого пакета с установленным glycin, но
# когда собираем первый раз (без glycin) явно указываем их отключение.
#    -D *=disabled
# Не позволяем meson загружать любые дополнительные зависимости, которые не
# установлены в системе
#    --wrap-mode=nofallback
meson setup ..              \
    --prefix=/usr           \
    --buildtype=release     \
    -D png=disabled         \
    -D gif=disabled         \
    -D jpeg=disabled        \
    -D tiff=disabled        \
    -D thumbnailer=disabled \
    --wrap-mode=nofallback  \
    -D glycin="${GLYCIN}" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
