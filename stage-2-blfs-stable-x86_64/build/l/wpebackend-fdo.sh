#! /bin/bash

PRGNAME="wpebackend-fdo"

### wpebackend-fdo (freedesktop.org backend for WPE WebKit)
# Серверная часть (backend) freedesktop.org для WPE Webkit

# Required:    libepoxy
#              libwpe
#              wayland-protocols
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

mkdir build
cd build || exit 1

meson                      \
    --prefix=/usr          \
    --buildtype=release    \
    -Dbuild_docs="${DOCS}" \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (freedesktop.org backend for WPE WebKit)
#
# WPE is the reference WebKit port for embedded and low-consumption computer
# devices. It has been designed from the ground-up with performance, small
# footprint, accelerated content rendering, and simplicity of deployment in
# mind, bringing the excellence of the WebKit engine to countless platforms and
# target devices. This is the freedesktop.org backend.
#
# Home page: https://wpewebkit.org/
# Download:  https://wpewebkit.org/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
