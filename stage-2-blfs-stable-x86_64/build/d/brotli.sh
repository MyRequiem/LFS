#! /bin/bash

PRGNAME="brotli"

### brotli (general-purpose lossless compression algorithm)
# Универсальный алгоритм сжатия данных. Метод сжатия brotli основан на
# современном варианте алгоритма LZ77, энтропийном кодировании Хаффмана и
# моделировании контекста 2-го порядка.

# Required:    cmake
# Recommended: no
# Optional:    python2 (для python2-bindings)
#              python3 (для python3-bindings)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему в файлах pkg-config
sed -i 's@-R..libdir.@@' scripts/*.pc.in

mkdir build
cd build || exit 1

cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

# собираем python-bindings
cd .. || exit 1

# python 2
if command -v python2 &>/dev/null; then
    python2 setup.py build || exit 1
    python2 setup.py install --optimize=1 --root="${TMP_DIR}"
fi

# python 3
if command -v python3 &>/dev/null; then
    python3 setup.py build || exit 1
    python3 setup.py install --optimize=1 --root="${TMP_DIR}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Download:  https://github.com/google/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
