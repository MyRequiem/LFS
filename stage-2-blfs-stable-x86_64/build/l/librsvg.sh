#! /bin/bash

PRGNAME="librsvg"

### librsvg (SVG library)
# Библиотека и инструменты для управления, преобразования и отрисовки
# масштабируемой векторной графики в формате SVG

# Required:    cairo
#              cargo-c
#              gdk-pixbuf
#              pango
# Recommended: glib
#              vala
# Optional:    python3-docutils     (для генерации man-страниц)
#              python3-gi-docgen    (для документации)
#              xorg-fonts           (для тестов)

###
# NOTE:
#    при сборке скачиваются дополнительные файлы из сети Internet, поэтому
#    пакет необходимо собирать в чистой среде LFS (не в среде chroot хоста)
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим путь установки API документации
sed -e "/OUTDIR/s|,| / 'librsvg-2.61.0', '--no-namespace-dir',|" \
    -e '/output/s|Rsvg-2.0|librsvg-2.61.0|'                      \
    -i doc/meson.build || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновляем файл /usr/lib/gdk-pixbuf-x.x/x.x.x/loaders.cache
gdk-pixbuf-query-loaders --update-cache

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (SVG library)
#
# The librsvg package contains a library and tools used to manipulate, convert
# and view Scalable Vector Graphic (SVG) images
#
# Home page: https://wiki.gnome.org/Projects/LibRsvg
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
