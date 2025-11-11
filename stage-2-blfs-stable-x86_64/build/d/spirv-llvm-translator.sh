#! /bin/bash

PRGNAME="spirv-llvm-translator"
ARCH_NAME="SPIRV-LLVM-Translator"

### SPIRV-LLVM-Translator (converting between LLVM IR and SPIR-V code)
# библиотека и утилита для преобразования между LLVM IR и SPIR-V-кодом

# Required:    libxml2
#              llvm
#              spirv-tools
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                              \
    -D CMAKE_INSTALL_PREFIX=/usr                   \
    -D CMAKE_BUILD_TYPE=Release                    \
    -D BUILD_SHARED_LIBS=ON                        \
    -D CMAKE_SKIP_INSTALL_RPATH=ON                 \
    -D LLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=/usr \
    -G Ninja                                       \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (converting between LLVM IR and SPIR-V code)
#
# The SPIRV-LLVM-Translator package contains a library and utility for
# converting between LLVM IR and SPIR-V code. This package currently only
# supports the OpenCL/Compute version of SPIR-V
#
# Home page: https://github.com/KhronosGroup/${ARCH_NAME}/
# Download:  https://github.com/KhronosGroup/${ARCH_NAME}/archive/v${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
