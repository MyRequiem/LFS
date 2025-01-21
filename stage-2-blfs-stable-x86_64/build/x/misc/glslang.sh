#! /bin/bash

PRGNAME="glslang"

### Glslang (frontend and validator for OpenGL, OpenGL ES and Vulkan shaders)
# Интерфейс и валидатор для OpenGL, OpenGL ES и Vulkan шейдеров

# Required:    cmake
#              spirv-tools
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                \
    -D CMAKE_INSTALL_PREFIX=/usr     \
    -D CMAKE_BUILD_TYPE=Release      \
    -D ALLOW_EXTERNAL_SPIRV_TOOLS=ON \
    -D BUILD_SHARED_LIBS=ON          \
    -D GLSLANG_TESTS=OFF             \
    -G Ninja                         \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (frontend and validator for OpenGL, OpenGL ES and Vulkan shaders)
#
# The Glslang package contains an frontend and validator for OpenGL, OpenGL ES,
# and Vulkan shaders
#
# Home page: https://github.com/KhronosGroup/glslang/
# Download:  https://github.com/KhronosGroup/glslang/archive/14.3.0/glslang-14.3.0.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
