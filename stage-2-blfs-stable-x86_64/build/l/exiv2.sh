#! /bin/bash

PRGNAME="exiv2"

### Exiv2 (Exif and IPTC metadata library and tools)
# C++ библиотека и утилита командной строки для чтения и записи Exif и IPTC
# метаданных изображений и видео

# Required:    cmake
# Recommended: brotli
#              curl
#              inih
# Optional:    libssh    (https://www.libssh.org/)
#              --- для документации ---
#              doxygen
#              graphviz
#              libxslt

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                              \
    -D CMAKE_INSTALL_PREFIX=/usr   \
    -D CMAKE_BUILD_TYPE=Release    \
    -D EXIV2_ENABLE_VIDEO=yes      \
    -D EXIV2_ENABLE_WEBREADY=yes   \
    -D EXIV2_ENABLE_CURL=yes       \
    -D EXIV2_BUILD_SAMPLES=no      \
    -D CMAKE_SKIP_INSTALL_RPATH=ON \
    -G Ninja                       \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

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
# Download:  https://github.com/Exiv2/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
