#! /bin/bash

PRGNAME="libtiff"
ARCH_NAME="tiff"

### LibTIFF (a library for reading and writing TIFF files)
# Пакет содержит библиотеки и утилиты для работы с изображениями в формате TIFF
# (Tag Image File Format)

# http://www.linuxfromscratch.org/blfs/view/9.0/general/libtiff.html

# Home page: http://simplesystems.org/libtiff/
# Download:  http://download.osgeo.org/libtiff/tiff-4.0.10.tar.gz

# Required:    no
# Recommended: cmake
# Optional:    freeglut (для сборки утилиты tiffgt)
#              libjpeg-turbo
#              libwebp
#              jbig-kit (http://www.cl.cam.ac.uk/~mgk25/jbigkit/)
#              zstd     (https://facebook.github.io/zstd/)

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

mkdir -p _build
cd _build || exit 1

cmake                                                             \
    -DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    -DCMAKE_INSTALL_PREFIX=/usr -G Ninja                          \
    .. || exit 1

ninja || exit 1
# ninja test
ninja install
DESTDIR="${TMP_DIR}" ninja install

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a library for reading and writing TIFF files)
#
# This package provides support for the Tag Image File Format (TIFF), a widely
# used format for storing image data. Included is the libtiff library (for
# reading and writing TIFF files), and a collection of tools for working with
# TIFF images.
#
# Home page: http://simplesystems.org/${PRGNAME}/
# Download:  http://download.osgeo.org/${PRGNAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
