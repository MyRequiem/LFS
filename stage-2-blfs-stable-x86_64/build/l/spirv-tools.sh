#! /bin/bash

PRGNAME="spirv-tools"
ARCH_NAME="SPIRV-Tools"

### SPIRV-Tools (libraries and utilities for processing SPIR-V modules)
# Библиотеки и утилиты для обработки модулей SPIR-V

# Required:    cmake
#              spirv-headers
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-vulkan-sdk-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd    build || exit 1

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
# Home page: https://github.com/KhronosGroup/${ARCH_NAME}/
# Download:  https://github.com/KhronosGroup/${ARCH_NAME}/archive/vulkan-sdk-${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
