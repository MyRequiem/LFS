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
#              python3-pygments
#              rsync                        (для тестов)
#              python3-recommonmark         (для создания документации)
#              texlive или install-tl-unx
#              valgrind
#              python3-pyyaml
#              zip
#              ocaml                 (https://ocaml.org/)
#              python3-psutil        (https://pypi.org/project/psutil/)
#              z3                    (https://github.com/Z3Prover/z3)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | rev | cut -d . -f 2- | rev)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN="/usr/share/man/man1"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"{"${MAN}","${DOCS}"}

tar -xvf "${SOURCES}/${PRGNAME}-cmake-${VERSION}.src.tar.xz"  || exit 1
sed '/LLVM_COMMON_CMAKE_UTILS/s@../cmake@cmake-15.0.7.src@' \
    -i CMakeLists.txt

tar -xvf "${SOURCES}/${CLANG}-${VERSION}.src.tar.xz"       -C tools    || exit 1
tar -xvf "${SOURCES}/${COMPILER_RT}-${VERSION}.src.tar.xz" -C projects || exit 1

mv "tools/${CLANG}-${VERSION}.src"          "tools/${CLANG}"
mv "projects/${COMPILER_RT}-${VERSION}.src" "projects/${COMPILER_RT}"

DOXYGEN="OFF"
SPHINX=""
RECOMMONMARK=""
LLVM_DOCS=""

# command -v doxygen      &>/dev/null          && DOXYGEN="ON"
# command -v sphinx-build &>/dev/null          && SPHINX="true"
# command -v cm2html      &>/dev/null          && RECOMMONMARK="true"
[[ -n "${SPHINX}" && -n "${RECOMMONMARK}" ]] && LLVM_DOCS="true"

# в исходниках лежит много Python-скриптов, которые используют shebang
# /usr/bin/env python для доступа к системному Python, который в LFS -
# Python-3.x.x. Исправим эти скрипты, чтобы shebang был /usr/bin/env python3
grep -rl '#!.*python' | xargs sed -i '1s/python$/python3/'

# включаем SSP по умолчанию в скомпилированных программах
patch --verbose -Np2 -d "tools/${CLANG}" < \
    "${SOURCES}/${CLANG}-${VERSION}-enable_default_ssp-1.patch" || exit 1

mkdir -v build
cd build || exit 1

# использовать libffi
#    -DLLVM_ENABLE_FFI=ON
# включаем оптимизацию компилятора для ускорения сборки, уменьшения размера
# бинарников и отключения некоторых проверок компиляции, которые не требуется в
# конечной системе
#    -DCMAKE_BUILD_TYPE=Release
# создаем статические библиотеки и связываем их в одну расшаренную
# (рекомендуемый способ создания расшаренной библиотеки)
#    -DLLVM_BUILD_LLVM_DYLIB=ON
# связываем инструменты с расшаренной библиотекой вместо статической. Также
# немного уменьшает их размер и гарантирует, что llvm-config будет правильно
# использовать библиотеку libLLVM.so
#    -DLLVM_LINK_LLVM_DYLIB=ON
# сборка LLVM с run-time type info (необходимо для сборки mesa)
#    -DLLVM_ENABLE_RTTI=ON
# набор целей, требуемый для сборки пакета v4l-utils по умолчанию. Допустимые
# цели: host, X86, Sparc, PowerPC, ARM, AArch64, Mips, Hexagon, Xcore, MSP430,
# NVPTX, SystemZ, AMDGPU, BPF, CppBackend, all
#    -DLLVM_TARGETS_TO_BUILD="host;AMDGPU;BPF"
#
###
# для тестов собираем LLVM unit tests
#    -DLLVM_BUILD_TESTS=ON
###
CC=gcc CXX=g++                                \
cmake                                         \
    -DCMAKE_INSTALL_PREFIX=/usr               \
    -DLLVM_ENABLE_FFI=ON                      \
    -DCMAKE_BUILD_TYPE=Release                \
    -DLLVM_BUILD_LLVM_DYLIB=ON                \
    -DLLVM_LINK_LLVM_DYLIB=ON                 \
    -DLLVM_ENABLE_RTTI=ON                     \
    -DLLVM_INCLUDE_BENCHMARKS=OFF             \
    -DLLVM_BUILD_TESTS=OFF                    \
    -DLLVM_ENABLE_DOXYGEN="${DOXYGEN}"        \
    -DLLVM_BINUTILS_INCDIR=/usr/include       \
    -DLLVM_TARGETS_TO_BUILD="host;AMDGPU;BPF" \
    -Wno-dev -G Ninja .. || exit 1

ninja || exit 1

# если пакеты python3-sphinx и python3-recommonmark установлены, сгенерируем
# html документацию и man-страницы для llvm и clang
if [ -n "${LLVM_DOCS}" ]; then
    cmake                               \
        -DLLVM_BUILD_DOCS=ON            \
        -DLLVM_ENABLE_SPHINX=ON         \
        -DSPHINX_WARNINGS_AS_ERRORS=OFF \
        -Wno-dev -G Ninja .. || exit 1

    ninja docs-llvm-html  docs-llvm-man
    ninja docs-clang-html docs-clang-man

    # doxygen документация llvm
    if [[ "${DOXYGEN}" == "ON" ]]; then
        make doxygen-html
    fi
fi

# тесты
# для тестов собираем LLVM unit tests с опцией конфигурации
#    -DLLVM_BUILD_TESTS=ON
# ninja check-all

DESTDIR="${TMP_DIR}" ninja install

chmod 644 "${TMP_DIR}${MAN}"/*

# установка документации llvm
cp -v ../LICENSE.TXT ../README.txt "${TMP_DIR}${DOCS}"

if [ -d docs/man ]; then
    install -v -m644 docs/man/* "${TMP_DIR}${MAN}"
fi

if [ -d docs/html ]; then
    install -v -d -m755 "${TMP_DIR}${DOCS}/llvm-html"
    cp -Rv docs/html/*  "${TMP_DIR}${DOCS}/llvm-html"
fi

# установка документации clang
if [ -d tools/clang/docs/man ]; then
    install -v -m644 tools/clang/docs/man/* "${TMP_DIR}${MAN}"
fi

if [ -d tools/clang/docs/html ]; then
    install -v -d -m755 "${TMP_DIR}${DOCS}/clang-html"
    cp -Rv tools/clang/docs/html/* "${TMP_DIR}${DOCS}/clang-html"
fi

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
# Home page: http://${PRGNAME}.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}-project/releases/download/${PRGNAME}org-${VERSION}/${PRGNAME}-${VERSION}.src.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
