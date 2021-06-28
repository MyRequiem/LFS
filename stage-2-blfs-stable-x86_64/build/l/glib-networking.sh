#! /bin/bash

PRGNAME="glib-networking"

### glib-networking (network-related giomodules for glib)
# Пакет содержит сетевые gio-модули для GLib

# Required:    glib
#              gnutls
#              gsettings-desktop-schemas
# Recommended: make-ca
# Optional:    libproxy (https://github.com/libproxy/libproxy)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

LIBPROXY="disabled"
command -v proxy &>/dev/null && LIBPROXY="enabled"

mkdir build
cd build || exit 1

meson                        \
    --prefix=/usr            \
    -Dlibproxy="${LIBPROXY}" \
    ..  || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (network-related giomodules for glib)
#
# Package contains Network related gio modules for GLib
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
