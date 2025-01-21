#! /bin/bash

PRGNAME="vulkan-headers"
ARCH_NAME="Vulkan-Headers"

### Vulkan-Headers (set of header files for build and link Vulkan API)
# Набор заголовочных файлов для сборки и связывания Vulkan API

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -G Ninja                     \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (set of header files for build and link Vulkan API)
#
# The Vulkan-Headers package contains a set of header files necessary to build
# and link applications against the Vulkan API
#
# Home page: https://github.com/KhronosGroup/${ARCH_NAME}/
# Download:  https://github.com/KhronosGroup/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
