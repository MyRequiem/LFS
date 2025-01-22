#! /bin/bash

PRGNAME="libvirt-glib"

### libvirt-glib (glib wrapper for libvirt)
# Обертка для libvirt, которая обеспечивает высокоуровневое
# объектно-ориентированное API для GLib

# Required:    libyajl
#              libvirt
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson ..                \
    --prefix=/usr       \
    --buildtype=release \
    -Ddocs=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (glib wrapper for libvirt)
#
# libvirt-glib wraps libvirt to provide a high-level object-oriented API better
# suited for glib-based applications, via three libraries:
#    - libvirt-glib    - GLib main loop integration & misc helper APIs
#    - libvirt-gconfig - GObjects for manipulating libvirt XML documents
#    - libvirt-gobject - GObjects for managing libvirt objects
#
# Home page: https://libvirt.org
# Download:  https://libvirt.org/sources/glib/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
