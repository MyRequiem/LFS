#! /bin/bash

PRGNAME="geocode-glib"

### Geocode GLib (convenience library for the geocoding)
# Удобная библиотека для разработчиков, которая упрощает работу с сервисами
# геолокации, позволяя преобразовывать адреса в географические координаты
# (геокодирование) и наоборот (обратное геокодирование)

# Required:    json-glib
#              libsoup3
# Recommended: glib
# Optional:    gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                 \
    --prefix=/usr           \
    --buildtype=release     \
    -D enable-gtk-doc=false \
    -D soup2=false          \
    .. || exit 1

ninja || exit 1
# LANG=C ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (convenience library for the geocoding)
#
# The Geocode GLib is a convenience library for the Yahoo! Place Finder APIs.
# The Place Finder web service allows you to do geocoding (finding longitude
# and latitude from an address), as well as reverse geocoding (finding an
# address from coordinates)
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
