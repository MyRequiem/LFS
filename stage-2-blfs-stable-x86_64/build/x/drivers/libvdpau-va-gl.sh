#! /bin/bash

PRGNAME="libvdpau-va-gl"

### libvdpau-va-gl (VDPAU driver with VA-API/OpenGL backend)
# Драйвер VDPAU с серверной частью VA-API/OpenGL

# Required:    cmake
#              libvdpau
#              libva
#              mesa
# Recommended: no
# Optional:    doxygen
#              graphviz
#              texlive или install-tl-unx

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${XORG_PREFIX}" \
    .. || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (VDPAU driver with VA-API/OpenGL backend)
#
# VDPAU driver with VA-API/OpenGL backend
#
# Home page: https://github.com/i-rinat/${PRGNAME}
# Download:  https://github.com/i-rinat/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
