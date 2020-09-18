#! /bin/bash

PRGNAME="brotli"

### brotli (general-purpose lossless compression algorithm)
# Универсальный алгоритм сжатия данных. Метод сжатия brotli основан на
# современном варианте алгоритма LZ77, энтропийном кодировании Хаффмана и
# моделировании контекста 2-го порядка.

# http://www.linuxfromscratch.org/blfs/view/stable/general/brotli.html

# Home page: https://github.com/google/brotli
# Download:  https://github.com/google/brotli/archive/v1.0.7/brotli-v1.0.7.tar.gz

# Required: cmake
# Optional: lua53   (для lua-bindings)
#           python2 (для python2-bindings)
#           python3 (для python3-bindings)

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | \
    head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev | cut -d v -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-v${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir _build
cd _build || exit 1

cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
# make test

make install
make install DESTDIR="${TMP_DIR}"

# собираем python-bindings
cd .. || exit 1

# python 2
if command -v python2 &>/dev/null; then
    python2 setup.py build || exit 1
    python2 setup.py install --optimize=1 --root="${TMP_DIR}"
    PYTHON2_VERSION=$(python -V 2>&1 | cut -f 2 -d ' ' | cut -d . -f 1-2)
    cp -vR "${TMP_DIR}/usr/lib/python${PYTHON2_VERSION}"/* \
        "/usr/lib/python${PYTHON2_VERSION}/"
fi

# python 3
if command -v python3 &>/dev/null; then
    python3 setup.py build || exit 1
    python3 setup.py install --optimize=1 --root="${TMP_DIR}"
    PYTHON3_VERSION=$(python3 -V 2>&1 | cut -f 2 -d' ' | cut -d . -f 1-2)
    cp -vR "${TMP_DIR}/usr/lib/python${PYTHON3_VERSION}"/* \
        "/usr/lib/python${PYTHON3_VERSION}/"
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (general-purpose lossless compression algorithm)
#
# Brotli is a generic-purpose lossless compression algorithm that compresses
# data using a combination of a modern variant of the LZ77 algorithm, Huffman
# coding and 2nd order context modeling, with a compression ratio comparable to
# the best currently available general-purpose compression methods. It is
# similar in speed with deflate but offers more dense compression.
#
# Home page: https://github.com/google/${PRGNAME}
# Download:  https://github.com/google/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-v${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
