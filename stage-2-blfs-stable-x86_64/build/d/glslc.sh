#! /bin/bash

PRGNAME="glslc"
ARCH_NAME="shaderc"

### glslc (command line compiler for OpenGL Shading Language)
# компилятор командной строки для языка OpenGL Shading от Google

# Required:    cmake
#              glslang
#              spirv-tools
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/bin"

# разрешим сборку с Glslang и SPIRV-Tools
sed '/build-version/d'   -i glslc/CMakeLists.txt            || exit 1
sed '/third_party/d'     -i CMakeLists.txt                  || exit 1
sed 's|SPIRV|glslang/&|' -i libshaderc_util/src/compiler.cc || exit 1

echo "\"${VERSION}\"" > glslc/src/build-version.inc

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D SHADERC_SKIP_TESTS=ON     \
    -G Ninja                     \
    .. || exit 1

ninja || exit 1
install -vm755 glslc/glslc "${TMP_DIR}/usr/bin"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (command line compiler for OpenGL Shading Language)
#
# The glslc program is Google's command line compiler for OpenGL Shading
# Language/High Level Shading Language (GLSL/HLSL) to Standard Portable
# Intermediate Representation (SPIR-V).
#
# Home page: https://github.com/google/${ARCH_NAME}/
# Download:  https://github.com/google/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
