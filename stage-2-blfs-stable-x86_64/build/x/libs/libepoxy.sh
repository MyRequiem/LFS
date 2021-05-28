#! /bin/bash

PRGNAME="libepoxy"

### libepoxy (OpenGL function pointer management library)
# Библиотека для управления указателями функций OpenGL

# Required:    mesa
# Recommended: no
# Optional:    doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

DOCS="false"
# command -v doxygen &>/dev/null && DOCS="true"

meson                \
    --prefix=/usr    \
    -Ddocs="${DOCS}" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (OpenGL function pointer management library)
#
# libepoxy is a library for handling OpenGL function pointer management
#
# Home page: https://github.com/anholt/${PRGNAME}
# Download:  https://github.com/anholt/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
