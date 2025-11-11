#! /bin/bash

PRGNAME="vulkan-loader"
ARCH_NAME="Vulkan-Loader"

### Vulkan-Loader (library which provides the Vulkan API)
# Библиотека, предоставляющая API Vulkan и обеспечивающая основную поддержку
# графических драйверов для Vulkan

# Required:    cmake
#              vulkan-headers
#              xorg-libraries
# Recommended: wayland
#              mesa             (runtime)
# Optional:    git              (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                              \
    -D CMAKE_INSTALL_PREFIX=/usr   \
    -D CMAKE_BUILD_TYPE=Release    \
    -D CMAKE_SKIP_INSTALL_RPATH=ON \
    -G Ninja                       \
    .. || exit 1

ninja|| exit 1

### тесты
# необходима сеть Internet и установленный пакет git
#
# sed "s/'git', 'clone'/&, '--depth=1', '-b', self.commit/" \
#     -i ../scripts/update_deps.py || exit 1
#
# cmake                 \
#     -D BUILD_TESTS=ON \
#     -D UPDATE_DEPS=ON \
#     .. || exit 1
#
# ninja || exit
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library which provides the Vulkan API)
#
# The Vulkan-Loader package contains a library which provides the Vulkan API
# and provides core support for graphics drivers for Vulkan
#
#
# Home page: https://github.com/KhronosGroup/${ARCH_NAME}/
# Download:  https://github.com/KhronosGroup/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
