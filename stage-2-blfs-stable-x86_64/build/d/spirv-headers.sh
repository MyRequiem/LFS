#! /bin/bash

PRGNAME="spirv-headers"
ARCH_NAME="SPIRV-Headers-vulkan-sdk"

### SPIRV-Headers (headers that allow for applications to use the SPIR-V language)
# Набор заголовочных файлов с определениями и константами для SPIR-V,
# универсального языка (промежуточного представления), на котором пишутся
# шейдеры для Vulkan. Они служат  «справочником» для компиляторов и
# инструментов, чтобы те могли правильно переводить графический код эффектов
# (шейдеров) в понятные видеокарте инструкции.

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
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (headers that allow for applications to use the SPIR-V language)
#
# The SPIRV-Headers package contains headers that allow for applications to use
# the SPIR-V language and instruction set with Vulkan. SPIR-V is a binary
# intermediate language for representing graphical shader stages and compute
# kernels for multiple Khronos APIs, including OpenGL and Vulkan
#
# Home page: https://github.com/KhronosGroup/SPIRV-Headers
# Download:  https://github.com/KhronosGroup/SPIRV-Headers/archive/vulkan-sdk-${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
