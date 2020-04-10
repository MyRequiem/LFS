#! /bin/bash

PRGNAME="cmake"

### CMake
# Современный набор инструментов, используемый для генерации Makefile

# http://www.linuxfromscratch.org/blfs/view/9.0/general/cmake.html

# Home page: https://cmake.org/
# Download:  https://cmake.org/files/v3.15/cmake-3.15.2.tar.gz

# Required:    libuv
# Recommended: zlib
#              bzip2
#              curl
#              expat
#              libarchive
# Optional:    qt5        (для Qt-based GUI)
#              subversion (для тестов)
#              sphinx     (для сборки документации)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# запрещаем приложениям, использующим cmake при сборке устанавливать файлы в
# /usr/lib64/
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake || exit 1

# заставляет CMake связываться с Zlib, Bzip2, cURL, Expat и libarchive которые
# уже установлены в системе
#    --system-libs
# не собирать GUI на основе Qt
#    --no-qt-gui
# использовать внутреннюю версию библиотеки JSON-C++ вместо системной
#    --no-system-jsoncpp
./bootstrap              \
    --prefix=/usr        \
    --system-libs        \
    --no-qt-gui          \
    --mandir=/share/man  \
    --no-system-jsoncpp  \
    --no-system-librhash \
    --docdir="/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# тесты
# известно что тест RunCMake.CommandLineTar не проходит
# NUMJOBS="$(($(nproc) + 1))"
# bin/ctest -j"${NUMJOBS}" -O "${PRGNAME}-${VERSION}-test.log"

make install
make install DESTDIR="${TMP_DIR}"

VER="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (cross-platform, open-source make system)
#
# The CMake package contains a modern toolset used for generating Makefiles. It
# is a successor of the auto-generated configure script and aims to be
# platform- and compiler-independent. CMake generates native makefiles and
# workspaces that can be used in the compiler environment of your choice.
#
# Home page: https://cmake.org/
# Download:  https://cmake.org/files/v${VER}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
