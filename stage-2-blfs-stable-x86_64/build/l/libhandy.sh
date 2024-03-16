#! /bin/bash

PRGNAME="libhandy"

### libhandy (additional UI components for gtk+3)
# библиотека дополнительных GTK+3 виджетов для использования при разработке
# пользовательских интерфейсов

# Required:    gtk+3
# Recommended: vala
# Optional:    gtk-doc
#              glade    (https://gitlab.gnome.org/GNOME/glade)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (additional UI components for gtk+3)
#
# The libhandy package provides additional GTK UI widgets for use in developing
# user interfaces
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
