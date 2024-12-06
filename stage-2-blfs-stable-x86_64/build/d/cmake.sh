#! /bin/bash

PRGNAME="cmake"

### CMake (cross-platform, open-source make system)
# Современный набор инструментов, используемый для генерации Makefile

# Required:    no
# Recommended: curl
#              libarchive
#              libuv
#              nghttp2
# Optional:    gcc            (для gfortran)
#              --- для тестов ---
#              git
#              mercurial
#              subversion
#              openjdk
#              qt6            (для сборки Qt-based GUI)
#              python3-sphinx (для сборки документации) https://pypi.org/project/Sphinx/
#              cppdap         (https://github.com/google/cppdap/)
#              jsoncpp        (https://github.com/open-source-parsers/jsoncpp/)
#              rhash          (https://rhash.sourceforge.io/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# запрещаем приложениям, использующим cmake при сборке устанавливать файлы в
# /usr/lib64/
sed -i '/"lib64"/s/64//' Modules/GNUInstallDirs.cmake || exit 1

ZLIB="--no-system-zlib"
NGHTTP2="--no-system-nghttp2"
BZIP2="--no-system-bzip2"
EXPAT="--no-system-expat"
CURL="--no-system-curl"
LIBARCHIVE="--no-system-libarchive"
QT_GUI="--no-qt-gui"

[ -x /usr/lib/libz.so ]             && ZLIB="--system-zlib"
[ -x /usr/lib/libnghttp2.so ]       && NGHTTP2="--system-nghttp2"
command -v bzip2        &>/dev/null && BZIP2="--system-bzip2"
command -v xmlwf        &>/dev/null && EXPAT="--system-expat"
command -v curl         &>/dev/null && CURL="--system-curl"
command -v bsdcat       &>/dev/null && LIBARCHIVE="--system-libarchive"
# command -v assistant    &>/dev/null && QT_GUI="--qt-gui"

# заставляет CMake связываться с Zlib, Bzip2, cURL, Expat и libarchive которые
# уже установлены в системе
#    --system-libs
# использовать внутренние версии библиотек JSON-C++, cppdap и rhash вместо
# системных
#    --no-system-jsoncpp
#    --no-system-cppdap
#    --no-system-librhash
./bootstrap              \
    --prefix=/usr        \
    --system-libs        \
    --mandir=/share/man  \
    --no-system-jsoncpp  \
    --no-system-cppdap   \
    --no-system-librhash \
    "${ZLIB}"            \
    "${NGHTTP2}"         \
    "${BZIP2}"           \
    "${EXPAT}"           \
    "${CURL}"            \
    "${LIBARCHIVE}"      \
    "${QT_GUI}"          \
    --docdir="/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# тесты
# NUMJOBS="$(nproc)"
# LC_ALL=en_US.UTF-8 && \
#     bin/ctest -j"${NUMJOBS}" -O "${PRGNAME}-${VERSION}-test.log"

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (cross-platform, open-source make system)
#
# The CMake package contains a modern toolset used for generating Makefiles. It
# is a successor of the auto-generated configure script and aims to be
# platform- and compiler-independent. CMake generates native makefiles and
# workspaces that can be used in the compiler environment of your choice.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/files/v${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
