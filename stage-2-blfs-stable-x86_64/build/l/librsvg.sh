#! /bin/bash

PRGNAME="librsvg"

### librsvg (SVG library)
# Библиотека и инструменты для управления, преобразования и отрисовки
# масштабируемой векторной графики в формате SVG

# Required:    cairo
#              gdk-pixbuf
#              pango
#              rustc
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

./configure           \
    --prefix=/usr     \
    --enable-vala     \
    --disable-static  \
    --disable-gtk-doc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# тесты
# cargo update --precise 0.3.36 time &&
# LC_ALL=C make check -k

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/gtk-doc"

# обновляем файл /usr/lib/gdk-pixbuf-x.x/x.x.x/loaders.cache
gdk-pixbuf-query-loaders --update-cache

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
