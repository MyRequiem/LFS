#! /bin/bash

PRGNAME="libshumate"

### libshumate (GTK-4 widget to display maps)
# GTK-4 виджет для отображения карт

# Required:    gtk4
#              libsoup3
#              protobuf-c
# Recommended: glib                 (для gnome-maps)
# Optional:    python3-gi-docgen
#              valgrind
#              sysprof              (https://wiki.gnome.org/Apps/Sysprof)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                \
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nodownload \
    -D gtk_doc=false       \
    ..  || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GTK-4 widget to display maps)
#
# The libshumate package contains a GTK-4 widget to display maps
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
