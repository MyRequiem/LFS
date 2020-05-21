#! /bin/bash

PRGNAME="exiv2"

### Exiv2 (Exif and IPTC Metadata Library and Tools)
# C++ библиотека и утилита командной строки для управления метаданными
# изображений и видео

# http://www.linuxfromscratch.org/blfs/view/stable/general/exiv2.html

# Home page: http://www.exiv2.org/
# Download:  http://www.exiv2.org/builds/exiv2-0.27.2-Source.tar.gz

# Required:    cmake
# Recommended: curl
# Optional:    libssh2
#              doxygen
#              graphviz
#              libxslt

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}-*.tar.?z*" \
    2>/dev/null | head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1,2 | rev)"
VERSION="$(echo "${ARCH_VERSION}" | cut -d - -f 1)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${ARCH_VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${ARCH_VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

CURL="OFF"
DOXYGEN=""
GRAPHVIZ=""
DOC="OFF"

command -v curl    &>/dev/null && CURL="ON"
command -v doxygen &>/dev/null && DOXYGEN="true"
command -v dot     &>/dev/null && GRAPHVIZ="true"

[[ -n "${DOXYGEN}" && -n "${GRAPHVIZ}" ]] && DOC="ON"

cmake                                                             \
    -DCMAKE_INSTALL_PREFIX=/usr                                   \
    -DCMAKE_BUILD_TYPE=Release                                    \
    -DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    -DEXIV2_ENABLE_VIDEO=ON                                       \
    -DEXIV2_ENABLE_WEBREADY=ON                                    \
    -DEXIV2_ENABLE_CURL="${CURL}"                                 \
    -DEXIV2_BUILD_SAMPLES=OFF                                     \
    -DEXIV2_BUILD_DOC="${DOC}"                                    \
    -G "Unix Makefiles"                                           \
    .. || exit 1

make || exit 1
[[ "${DOC}" == "ON" ]] && make doc

# пакет не имеет набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Exif and IPTC Metadata Library and Tools)
#
# Exiv2 is a C++ library and a command line utility for managing image and
# video metadata.
#
# Home page: http://www.exiv2.org/
# Download:  http://www.exiv2.org/builds/${PRGNAME}-${ARCH_VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
