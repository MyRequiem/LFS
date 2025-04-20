#! /bin/bash

PRGNAME="llvm"
CLANG="clang"
COMPILER_RT="compiler-rt"

### LLVM (Low Level Virtual Machine compiler toolkit)
# Набор компиляторов из языков высокого уровня, системы оптимизации,
# интерпретации и компиляции в машинный код. В основе инфраструктуры
# используется RISC-подобная платформонезависимая система кодирования машинных
# инструкций (байткод LLVM IR), которая представляет собой высокоуровневый
# ассемблер, с которым работают различные преобразования. Написан на C++,
# обеспечивает оптимизации на этапах компиляции, компоновки и исполнения.
# Изначально в проекте были реализованы компиляторы для языков Си и C++ при
# помощи фронтенда Clang, позже появились фронтенды для множества языков, в том
# числе: ActionScript, Ада, C#, Common Lisp, Crystal, CUDA, D, Delphi, Dylan,
# Fortran, Graphical G Programming Language, Halide, Haskell, Java (байткод),
# JavaScript, Julia, Kotlin, Lua, Objective-C, OpenGL Shading Language, Ruby,
# Rust, Scala, Swift, Xojo. LLVM создает машинный код для множества архитектур,
# в том числе ARM, x86, x86-64, PowerPC, MIPS, SPARC, RISC-V и других (включая
# GPU от Nvidia и AMD).

# Required:    cmake
# Recommended: no
# Optional:    doxygen
#              git
#              graphviz
#              libxml2
#              python3-psutil
#              python3-pygments
#              python3-pyyaml
#              rsync
#              texlive или install-tl-unx
#              valgrind
#              zip
#              python3-myst-parser          (https://pypi.org/project/myst-parser/)
#              ocaml                        (https://ocaml.org/)
#              z3                           (https://github.com/Z3Prover/z3)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | rev | cut -d . -f 2- | rev)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -p "${TMP_DIR}/etc/clang"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"

# llvm-cmake
tar -xvf "${SOURCES}/${PRGNAME}-cmake-${MAJ_VERSION}.src.tar.xz"       || exit 1
sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@llvm-cmake-18.src@' \
    -i CMakeLists.txt || exit 1

# llvm-third-party
tar -xvf "${SOURCES}/${PRGNAME}-third-party-${MAJ_VERSION}.src.tar.xz" || exit 1
sed '/LLVM_THIRD_PARTY_DIR/s@../third-party@llvm-third-party-18.src@' \
    -i cmake/modules/HandleLLVMOptions.cmake || exit 1

# clang
tar -xvf "${SOURCES}/${CLANG}-${VERSION}.src.tar.xz"       -C tools    || exit 1
mv "tools/${CLANG}-${VERSION}.src"          "tools/${CLANG}"

# compiler-rt
tar -xvf "${SOURCES}/${COMPILER_RT}-${VERSION}.src.tar.xz" -C projects || exit 1
mv "projects/${COMPILER_RT}-${VERSION}.src" "projects/${COMPILER_RT}"

# в исходниках лежит много Python-скриптов, которые используют shebang
# /usr/bin/env python для доступа к системному Python, который в LFS -
# Python-3.x.x. Исправим эти скрипты, чтобы shebang был /usr/bin/env python3
grep -rl '#!.*python' | xargs sed -i '1s/python$/python3/'

sed 's/utility/tool/' -i utils/FileCheck/CMakeLists.txt

mkdir build
cd build || exit 1

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
    -D LLVM_BINUTILS_INCDIR=/usr/include       \
    -D LLVM_INCLUDE_BENCHMARKS=OFF             \
    -D CLANG_DEFAULT_PIE_ON_LINUX=ON           \
    -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang \
    -D LLVM_BUILD_TESTS=OFF                    \
    -D LLVM_ENABLE_DOXYGEN=OFF                 \
    -W no-dev -G Ninja .. || exit 1

ninja || exit 1

# тесты
#    rm -f ../projects/compiler-rt/test/tsan/getline_nohang.cpp
#    sh -c 'ulimit -c 0 && ninja check-all'

DESTDIR="${TMP_DIR}" ninja install

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
# Download:  https://github.com/${PRGNAME}/${PRGNAME}-project/releases/download/${PRGNAME}org-${VERSION}/${PRGNAME}-${VERSION}.src.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
