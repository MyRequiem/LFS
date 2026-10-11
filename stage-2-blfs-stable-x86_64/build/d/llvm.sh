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
#              python3-psutil               (для тестов)
#              python3-pygments
#              python3-pyyaml
#              rsync                        (для тестов)
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

# Исправим shebang для python-скриптов.
#    #! /usr/bin/env python -> #! /usr/bin/env python3
grep -rl '#!.*python$' | xargs sed -i '1s/python$/python3/'

# Будем устанавливать утилиту filecheck, которая требуется для тестирования
# некоторых пакетов (например rustc).
sed 's/utility/tool/' -i "${PRGNAME}/utils/FileCheck/CMakeLists.txt" || exit 1

# Включаем сильную защиту стека (SSP) в Clang. Создаваемые файлы конфигурации
# гарантируют, что дефолтное поведение Clang и Clang++ будет полностью
# идентично нашему Toolchain на базе GCC-16.2.0.
for CFG in clang clang++; do
    echo -fstack-protector-strong > "${TMP_DIR}/etc/clang/${CFG}.cfg"
done

mkdir -pv "${PRGNAME}/build"
cd "${PRGNAME}/build" || exit 1

# ---------------------------
# LLVM_TARGETS_TO_BUILD
# ---------------------------
# Определяет, для каких архитектур (GPU/CPU) компилятор будет генерировать
# машинный код. Ограничение списка экономит тонну времени сборки и дискового
# пространства.
#
# ВЫБОР ТАРГЕТОВ (в зависимости от видеокарты):
# 1. host   - Всегда ОБЯЗАТЕЛЕН. Включает бэкенд для процессора (x86_64).
# 2. AMDGPU - Нужен для открытых драйверов AMD (Mesa: radeonsi / radv).
# 3. NVPTX  - Нужен для открытых драйверов Nvidia (Mesa: nouveau).
#
# ВАЖНОЕ ПРИМЕЧАНИЕ ПО ЖЕЛЕЗУ:
#    - Для графики Intel (Iris/Arc) отдельного таргета в LLVM нет! Видеокарты
#      Intel используют собственный компилятор внутри Mesa, им достаточно
#      одного "host".
#    - Для закрытого драйвера Nvidia (Proprietary Blob) тоже достаточно одного
#      "host", так как блоб использует свой собственный встроенный компилятор
#      шейдеров.
#
# ПРИМЕРЫ НАСТРОЕК:
#    - Только для AMD:                       "host;AMDGPU"
#    - Только для Nvidia:                    "host;NVPTX"
#    - Только для Intel или закрытой Nvidia: "host"
#    - Универсальная сборка (все сразу):     "host;AMDGPU;NVPTX"
#
# --------------------
# LLVM_ENABLE_PROJECTS
# --------------------
# Определяет встроенные проекты для компиляции. Мы явно собираем "clang",
# который необходим для сборки Rust и браузеров. При этом мы полностью
# исключаем "libclc" (OpenCL), избавляя систему от проблемного балласта и кучи
# "sed"-костылей для раскладки заголовков.

CC=gcc CXX=g++                                 \
cmake                                          \
    -D CMAKE_INSTALL_PREFIX=/usr               \
    -D CMAKE_SKIP_INSTALL_RPATH=ON             \
    -D LLVM_ENABLE_FFI=ON                      \
    -D CMAKE_BUILD_TYPE=Release                \
    -D LLVM_BUILD_LLVM_DYLIB=ON                \
    -D LLVM_LINK_LLVM_DYLIB=ON                 \
    -D LLVM_ENABLE_RTTI=ON                     \
    -D LLVM_TARGETS_TO_BUILD="host"            \
    -D LLVM_ENABLE_PROJECTS=clang              \
    -D LLVM_ENABLE_RUNTIMES=compiler-rt        \
    -D LLVM_BINUTILS_INCDIR=/usr/include       \
    -D LLVM_INCLUDE_BENCHMARKS=OFF             \
    -D CLANG_DEFAULT_PIE_ON_LINUX=ON           \
    -D CLANG_CONFIG_FILE_SYSTEM_DIR=/etc/clang \
    -W no-author                               \
    -G Ninja                                   \
    .. || exit 1

ninja || exit 1

# Тесты.
# sh -c 'ulimit -c 0 && ninja check-all'

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
# Download:  https://github.com/${PRGNAME}/${PRGNAME}-project/releases/download/${PRGNAME}org-${VERSION}/${ARCH_NAME}-${VERSION}.src.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
