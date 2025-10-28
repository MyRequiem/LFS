#! /bin/bash

PRGNAME="openjpeg"

### OpenJPEG (JPEG2000 Codec)
# Реализация стандарта JPEG-2000 с открытым исходным кодом. OpenJPEG полностью
# соответствует спецификациям JPEG-2000 и может сжимать/распаковывать 16-битные
# изображения без потерь качества.

# Required:    cmake
# Recommended: no
# Optional:    git      (для тестов)
#              lcms2
#              libpng
#              libtiff
#              doxygen  (для сборки API документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/share"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_BUILD_TYPE=Release  \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D BUILD_STATIC_LIBS=OFF     \
    -D BUILD_DOC=OFF             \
    .. || exit 1

make || exit 1

# тесты
# git clone https://github.com/uclouvain/openjpeg-data.git --depth 1 || exit 1
# OPJ_DATA_ROOT="${PWD}/openjpeg-data" cmake -D BUILD_TESTING=ON ..  || exit 1
# make                                                               || exit 1
# make test

make install DESTDIR="${TMP_DIR}"

# если не собирали документацию, то и man-страницы не устанавливаются, исправим
cp -rv ../doc/man -T "${TMP_DIR}/usr/share/man"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (JPEG2000 Codec)
#
# OpenJPEG is an open-source implementation of the JPEG-2000 standard. OpenJPEG
# fully respects the JPEG-2000 specifications and can compress/decompress
# lossless 16-bit images.
#
# Home page: https://www.${PRGNAME}.org
# Download:  https://github.com/uclouvain/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
