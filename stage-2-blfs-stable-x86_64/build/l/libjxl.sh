#! /bin/bash

PRGNAME="libjxl"

### libjxl (reference implementation of the JPEG XL image format)
# Эталонная реализация формата JPEG XL

# Required:    brotli
#              cmake
#              giflib
#              highway
#              lcms2
#              libjpeg-turbo
#              libpng
# Recommended: gdk-pixbuf
# Optional:    python3-asciidoc     (для man-страниц)
#              doxygen
#              graphviz
#              java или openjdk
#              libavif
#              libwebp
#              gtest                (https://github.com/google/googletest)
#              openexr              (https://www.openexr.com/)
#              sjpeg                (https://github.com/webmproject/sjpeg)
#              skcms                (https://skia.googlesource.com/skcms/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                        \
    -D CMAKE_INSTALL_PREFIX=/usr             \
    -D CMAKE_BUILD_TYPE=Release              \
    -D BUILD_TESTING=OFF                     \
    -D BUILD_SHARED_LIBS=ON                  \
    -D JPEGXL_ENABLE_SKCMS=OFF               \
    -D JPEGXL_ENABLE_SJPEG=OFF               \
    -D JPEGXL_ENABLE_PLUGINS=ON              \
    -D JPEGXL_INSTALL_JARDIR=/usr/share/java \
    -G Ninja                                 \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим GdkPixbuf кэш
gdk-pixbuf-query-loaders --update-cache

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (reference implementation of the JPEG XL image format)
#
# The libjxl package contains the reference implementation of the JPEG XL image
# format
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
