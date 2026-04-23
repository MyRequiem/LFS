#! /bin/bash

PRGNAME="libclc"
ARCH_NAME="llvm-project"

### libclc (implementation of the library requirements OpenCL C)
# Набор функций для выполнения сложных математических вычислений прямо на
# видеокарте (OpenCL).

# Required:    spirv-llvm-translator
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

VERSION="$(echo "${VERSION}" | rev | cut -d . -f 2- | rev)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr"/{include/clc,lib/pkgconfig}

mkdir -pv "${PRGNAME}/build"
cd "${PRGNAME}/build" || exit 1

# Конфигурация TARGETS для драйверов:
#    * Intel и универсальной поддержки OpenCL в Mesa
#       spirv-mesa3d-
#       spirv64-mesa3d-
#    * NVIDIA
#       nvptx64--
#       nvptx64--nvidiacl
#       nvptx64-nvidia-cuda
#    * AMD
#       amdgcn--
#       amdgcn-amd-amdhsa
#       amdgcn-mesa-mesa3d
#       r600--
#    * clspv - это специальный компилятор от Google, который переводит код
#      OpenCL C в шейдеры Vulkan (SPIR-V). В 99% случаев он не нужен. В Mesa
#      для OpenCL используется либо старый драйвер Clover, либо новый Rusticl,
#      и они полагаются на таргеты spirv-mesa3d-, а не на clspv
#       clspv--
#       clspv64--
TRGTS="spirv-mesa3d-;spirv64-mesa3d-;nvptx64--;nvptx64--nvidiacl;nvptx64-nvidia-cuda"
cmake                                     \
    -D CMAKE_INSTALL_PREFIX=/usr          \
    -D CMAKE_BUILD_TYPE=Release           \
    -D LIBCLC_TARGETS_TO_BUILD="${TRGTS}" \
    -G Ninja                              \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# Разработчики llvm-project, зачем вы кидаете заголовки куда попало? Наведем
# порядок:
cp -vpR ../clc/include/clc/*          "${TMP_DIR}/usr/include/clc/"
cp -vpR ../clc/include/clc/internal/* "${TMP_DIR}/usr/include/clc/"
rm -rf "${TMP_DIR}/usr/include/clc/internal"

cp -vpR ../opencl/include/* "${TMP_DIR}/usr/include/"

rm -rf "${TMP_DIR}/usr/share/pkgconfig"
cat << EOF > "${TMP_DIR}/usr/lib/pkgconfig/libclc.pc"
prefix=/usr
includedir=\${prefix}/include
libexecdir=\${prefix}/share/clc

Name: libclc
Description: Library requirements of the OpenCL C programming language
Version: 0.2.0
Cflags: -I\${includedir}
Libs: -L\${libexecdir}
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (implementation of the library requirements OpenCL C)
#
# The libclc package contains an implementation of the library requirements of
# the OpenCL C programming language, as specified by the OpenCL 1.1
# Specification
#
# Home page: https://libclc.llvm.org/
# Download:  https://github.com/llvm/${ARCH_NAME}/releases/download/llvmorg-${VERSION}/${ARCH_NAME}-${VERSION}.src.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
