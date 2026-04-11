#! /bin/bash

PRGNAME="llvm"
ARCH_NAME="llvm-project"

### LLVM (Low Level Virtual Machine compiler toolkit)
# Громадный каркас для построения компиляторов и инструментов анализа кода. Без
# него не смогут работать современные видеодрайверы и сложные языки
# программирования.

# Required:    cmake
# Recommended: no
# Optional:    doxygen
#              git
#              graphviz
#              libunwind
#              libxml2
#              python3-psutil
#              python3-pygments
#              python3-pyyaml
#              rsync
#              python3-sphinx
#              texlive или install-tl-unx
#              valgrind
#              zip
#              python3-myst-parser          (https://pypi.org/project/myst-parser/)
#              ocaml                        (https://ocaml.org/)
#              z3                           (https://github.com/Z3Prover/z3)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

VERSION="$(echo "${VERSION}" | rev | cut -d . -f 2- | rev)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -p "${TMP_DIR}/etc/clang"

# исправим shebang для python-скриптов:
#    #! /usr/bin/env python -> #! /usr/bin/env python3
grep -rl '#!.*python$' | xargs sed -i '1s/python$/python3/'

# будем устанавливать утилиту filecheck, которая требуется для тестирования
# некоторых пакетов (например rustc)
sed 's/utility/tool/' -i llvm/utils/FileCheck/CMakeLists.txt || exit 1

mkdir -v llvm/build
cd llvm/build || exit 1

CC=gcc CXX=g++                                 \
cmake                                          \
    -D CMAKE_INSTALL_PREFIX=/usr               \
    -D CMAKE_SKIP_INSTALL_RPATH=ON             \
    -D LLVM_ENABLE_FFI=ON                      \
    -D CMAKE_BUILD_TYPE=Release                \
    -D LLVM_BUILD_LLVM_DYLIB=ON                \
    -D LLVM_LINK_LLVM_DYLIB=ON                 \
    -D LLVM_ENABLE_RTTI=ON                     \
    -D LLVM_TARGETS_TO_BUILD="host;AMDGPU"     \
    -D LLVM_ENABLE_PROJECTS=clang              \
    -D LLVM_ENABLE_RUNTIMES=compiler-rt        \
    -D LLVM_BINUTILS_INCDIR=/usr/include       \
    -D LLVM_INCLUDE_BENCHMARKS=OFF             \
    -D CLANG_DEFAULT_PIE_ON_LINUX=ON           \
    -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang \
    -W no-dev                                  \
    -G Ninja                                   \
    .. || exit 1

ninja || exit 1

# тесты
# sh -c 'ulimit -c 0 && ninja check-all'

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

for CFG in clang clang++; do
    echo -fstack-protector-strong > "${TMP_DIR}/etc/clang/${CFG}.cfg"
done

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Low Level Virtual Machine compiler toolkit)
#
# The LLVM package contains a collection of modular and reusable compiler and
# toolchain technologies. The Low Level Virtual Machine (LLVM) Core libraries
# provide a modern source and target-independent optimizer, along with code
# generation support for many popular CPUs (as well as some less common ones!).
# These libraries are built around a well specified code representation known
# as the LLVM intermediate representation ("LLVM IR"). The optional Clang and
# Compiler RT packages provide new C, C++, Objective C and Objective C++
# front-ends and runtime libraries for the LLVM and are required by some
# packages which use Rust, for example Mozilla Firefox.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}-project/releases/download/${PRGNAME}org-${VERSION}/${PRGNAME}-project-${VERSION}.src.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
