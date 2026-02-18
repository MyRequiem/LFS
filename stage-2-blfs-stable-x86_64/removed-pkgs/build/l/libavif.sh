#! /bin/bash

PRGNAME="libavif"

### libavif (encoding and decoding AVIF files)
# Библиотека для кодирования и декодирования AVIF файлов

# Required:    libaom
# Recommended: gdk-pixbuf
# Optional:    gtest        (https://github.com/google/googletest)
#              libdav1d     (https://code.videolan.org/videolan/dav1d)
#              libyuv       (https://chromium.googlesource.com/libyuv/libyuv/)
#              rav1e        (https://github.com/xiph/rav1e)
#              svt-av1      (https://gitlab.com/AOMediaCodec/SVT-AV1)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D AVIF_CODEC_AOM=SYSTEM     \
    -D AVIF_BUILD_GDK_PIXBUF=ON  \
    -D AVIF_LIBYUV=OFF           \
    -G Ninja                     \
    .. || exit 1

ninja || exit 1

### тесты
# cmake .. -D AVIF_GTEST=LOCAL -D AVIF_BUILD_TESTS=ON || exit 1
# ninja && ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим GdkPixbuf кэш
gdk-pixbuf-query-loaders --update-cache

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (encoding and decoding AVIF files)
#
# The libavif package contains a library used for encoding and decoding AVIF
# files
#
# Home page: https://github.com/AOMediaCodec/${PRGNAME}/
# Download:  https://github.com/AOMediaCodec/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
