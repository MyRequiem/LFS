#! /bin/bash

PRGNAME="openjpeg"

### OpenJPEG (JPEG2000 Codec)
# Реализация стандарта JPEG-2000 с открытым исходным кодом. OpenJPEG полностью
# соответствует спецификациям JPEG-2000 и может сжимать/распаковывать 16-битные
# изображения без потерь качества.

# http://www.linuxfromscratch.org/blfs/view/stable/general/openjpeg2.html

# Home page: http://www.openjpeg.org
# Download:  https://github.com/uclouvain/openjpeg/archive/v2.3.1/openjpeg-2.3.1.tar.gz

# Required: cmake
# Optional: lcms2
#           libpng
#           libtiff
#           doxygen (для сборки html документации)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -v build
cd build || exit 1

cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
    -DBUILD_STATIC_LIBS=OFF     \
    .. || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

# html документация
if command -v doxygen &>/dev/null; then
    make clean
    cmake                           \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release  \
        -DBUILD_STATIC_LIBS=OFF     \
        -DBUILD_DOC=ON              \
        .. || exit 1
        make doc || exit 1

    DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -m755 -d "${DOCS}/html"
    install -v -m755 -d "${TMP_DIR}${DOCS}/html"
    cp -vR doc/html/* "${DOCS}/html"
    cp -vR doc/html/* "${TMP_DIR}${DOCS}/html"
fi

# man-страницы
pushd ../doc || exit 1
    for MAN in man/man?/*; do
        install -vD -m 644 "${MAN}" "/usr/share/${MAN}"
        install -vD -m 644 "${MAN}" "${TMP_DIR}/usr/share/${MAN}"
    done
popd || exit 1

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (JPEG2000 Codec)
#
# OpenJPEG is an open-source implementation of the JPEG-2000 standard. OpenJPEG
# fully respects the JPEG-2000 specifications and can compress/decompress
# lossless 16-bit images.
#
# Home page: http://www.openjpeg.org
# Download:  https://github.com/uclouvain/openjpeg/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
