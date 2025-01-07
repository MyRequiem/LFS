#! /bin/bash

PRGNAME="libtiff"
ARCH_NAME="tiff"

### LibTIFF (a library for reading and writing TIFF files)
# Библиотеки и утилиты для работы с изображениями в формате TIFF (Tag Image
# File Format)

# Required:    cmake
# Recommended: no
# Optional:    freeglut       (для сборки утилиты tiffgt)
#              libjpeg-turbo
#              python3-sphinx
#              libwebp
#              jbig-kit       (http://www.cl.cam.ac.uk/~mgk25/jbigkit/)
#              lerc           (https://www.osgeo.org/projects/lerc-limited-error-raster-compression/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p libtiff-build
cd libtiff-build || exit 1

cmake                                                              \
    -D CMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    -D CMAKE_INSTALL_PREFIX=/usr                                   \
    -G Ninja .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a library for reading and writing TIFF files)
#
# This package provides support for the Tag Image File Format (TIFF), a widely
# used format for storing image data. Included is the libtiff library (for
# reading and writing TIFF files), and a collection of tools for working with
# TIFF images.
#
# Home page: https://${PRGNAME}.gitlab.io/${PRGNAME}/
# Download:  https://download.osgeo.org/${PRGNAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
