#! /bin/bash

PRGNAME="brotli"

### brotli (general-purpose lossless compression algorithm)
# Универсальный алгоритм сжатия данных. Метод сжатия brotli основан на
# современном варианте алгоритма LZ77, энтропийном кодировании Хаффмана и
# моделировании контекста 2-го порядка.

# Required:    cmake
# Recommended: no
# Optional:    python3-pytest (для тестов)

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
    .. || exit 1

make || exit 1
# make test

# сразу устанавливаем пакет в систему для сборки Python3 bindings
make install
make install DESTDIR="${TMP_DIR}"

cd .. || exit 1

# Python3 bindings
# не позволяем скрипту setup.py заново собирать весь пакет, вместо этого
# используем уже установленные библиотеки
sed "/c\/.*\.[ch]'/d;\
     /include_dirs=\[/\
     i libraries=['brotlicommon','brotlidec','brotlienc']," \
    -i setup.py || exit 1

pip3 wheel               \
    -w dist              \
    --no-build-isolation \
    --no-deps            \
    --no-cache-dir       \
    "${PWD}" || exit 1

pip3 install            \
    --root="${TMP_DIR}" \
    --no-index          \
    --find-links dist   \
    --no-user           \
    Brotli || exit 1

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
