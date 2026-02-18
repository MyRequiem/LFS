#! /bin/bash

PRGNAME="opencv"

### opencv (Open Source Computer Vision)
# Графические библиотеки, в основном предназначенные для работы в режиме
# реального времени

# Required:    cmake
#              libarchive
# Recommended: ffmpeg
#              gst-plugins-base
#              gtk+3
#              jasper
#              libavif
#              libexif
#              libjpeg-turbo
#              libpng
#              libtiff
#              libwebp
#              openjpeg
#              v4l-utils
#              xine-lib
# Optional:    apache-ant
#              doxygen
#              java или openjdk
#              numpy
#              protobuf
#              atlas                (https://math-atlas.sourceforge.net/)
#              blas                 (https://www.netlib.org/blas/)
#              cuda                 (https://developer.nvidia.com/cuda-zone)
#              eigen                (https://eigen.tuxfamily.org/)
#              openexr              (https://www.openexr.com/)
#              gdal                 (https://www.gdal.org/)
#              lapack               (https://www.netlib.org/lapack/)
#              libdc1394            (https://sourceforge.net/projects/libdc1394/)
#              tbb                  (https://github.com/oneapi-src/oneTBB)
#              vtk                  (https://vtk.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                                   \
    -D CMAKE_INSTALL_PREFIX=/usr        \
    -D CMAKE_BUILD_TYPE=Release         \
    -D ENABLE_CXX11=ON                  \
    -D BUILD_PERF_TESTS=OFF             \
    -D WITH_XINE=ON                     \
    -D BUILD_TESTS=OFF                  \
    -D ENABLE_PRECOMPILED_HEADERS=OFF   \
    -D CMAKE_SKIP_INSTALL_RPATH=ON      \
    -D BUILD_WITH_DEBUG_INFO=OFF        \
    -D OPENCV_GENERATE_PKGCONFIG=ON     \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -W no-dev                           \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Open Source Computer Vision)
#
# The opencv package contains graphics libraries mainly aimed at real-time
# computer vision
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
