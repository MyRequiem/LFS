#! /bin/bash

PRGNAME="spirv-tools"
ARCH_NAME="SPIRV-Tools-vulkan-sdk"

### SPIRV-Tools (libraries and utilities for processing SPIR-V modules)
# Библиотеки и утилиты для обработки модулей SPIR-V

# Required:    cmake
#              spirv-headers
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                \
    -D CMAKE_INSTALL_PREFIX=/usr     \
    -D CMAKE_BUILD_TYPE=Release      \
    -D SPIRV_WERROR=OFF              \
    -D BUILD_SHARED_LIBS=ON          \
    -D SPIRV_TOOLS_BUILD_STATIC=OFF  \
    -D SPIRV-Headers_SOURCE_DIR=/usr \
    -G Ninja                         \
    .. || exit 1

ninja|| exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (libraries and utilities for processing SPIR-V modules)
#
# The SPIRV-Tools package contains libraries and utilities for processing
# SPIR-V modules
#
# Home page: https://github.com/KhronosGroup/SPIRV-Tools/
# Download:  https://github.com/KhronosGroup/SPIRV-Tools/archive/vulkan-sdk-${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
