#! /bin/bash

PRGNAME="openjpeg"

### OpenJPEG (JPEG2000 Codec)
# Реализация стандарта JPEG-2000 с открытым исходным кодом. OpenJPEG полностью
# соответствует спецификациям JPEG-2000 и может сжимать/распаковывать 16-битные
# изображения без потерь качества.

# Required:    cmake
# Recommended: no
# Optional:    lcms2
#              libpng
#              libtiff
#              doxygen (для сборки API документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="OFF"
# command -v doxygen &>/dev/null && DOCS="ON"

mkdir build
cd build || exit 1

cmake                           \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_STATIC_LIBS=OFF     \
    -DBUILD_DOC="${DOCS}"  \
    .. || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

# если не собирали документацию, то и man-страницы не устанавливаются, исправим
if [[ "x${DOCS}" == "xOFF" ]]; then
    mkdir -p "${TMP_DIR}/usr/share"
    cp -vR ../doc/man "${TMP_DIR}/usr/share"
fi

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
# Home page: http://www.${PRGNAME}.org
# Download:  https://github.com/uclouvain/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
