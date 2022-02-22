#! /bin/bash

PRGNAME="exiv2"

### Exiv2 (Exif and IPTC metadata library and tools)
# C++ библиотека и утилита командной строки для чтения и записи Exif и IPTC
# метаданных изображений и видео

# Required:    cmake
# Recommended: curl
# Optional:    libssh (https://www.libssh.org/)
#              doxygen
#              graphviz
#              libxslt

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 2 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}-Source".tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}-Source" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
    -DEXIV2_ENABLE_VIDEO=yes    \
    -DEXIV2_ENABLE_WEBREADY=yes \
    -DEXIV2_ENABLE_CURL=yes     \
    -DEXIV2_BUILD_SAMPLES=no    \
    -G "Unix Makefiles"         \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Exif and IPTC metadata library and tools)
#
# Exiv2 is a C++ library and a command line utility to read and write Exif and
# IPTC image and video metadata.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://github.com/Exiv2/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}-Source.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
