#! /bin/bash

PRGNAME="maim"

### maim (make image)
# Утилита для создания скриншотов

# Required:    cmake
#              glm
#              imlib2
#              libpng
#              libwebp
#              libjpeg-turbo
#              xorgproto
#              xorg-libraries
#              slop
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake ..                                \
    -D CMAKE_INSTALL_PREFIX=/usr        \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -W no-dev || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (make image)
#
# maim (make image) is an utility that takes a screenshot of your desktop, and
# encodes a png, jpg, bmp or webp image of it. By default it outputs the
# encoded image data directly to standard output. It's meant to overcome
# shortcomings of scrot and performs better in several ways.
#
# Home page: https://github.com/naelstrof/${PRGNAME}
# Download:  https://github.com/naelstrof/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
