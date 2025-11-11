#! /bin/bash

PRGNAME="snappy"

### snappy (A fast compressor/decompressor)
# Библиотека для быстрого сжатия и распаковки данных, написанная на C++ в
# Google на основе LZ77. Основной целью стало достижение высокой скорости
# сжатия, при этом задач наибольшего сжатия или совместимости с другими
# библиотеками не ставилось. Является хорошо переносимой, не использует
# ассемблерные вставки.

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p build
cd build || exit 1

cmake                                   \
    -D CMAKE_INSTALL_PREFIX=/usr        \
    -D CMAKE_BUILD_TYPE="Release"       \
    -D BUILD_SHARED_LIBS=ON             \
    -D SNAPPY_BUILD_TESTS=OFF           \
    -D SNAPPY_BUILD_BENCHMARKS=OFF      \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A fast compressor/decompressor)
#
# Snappy is a compression/decompression library. It does not aim for maximum
# compression, or compatibility with any other compression library; instead, it
# aims for very high speeds and reasonable compression. For instance, compared
# to the fastest mode of zlib, Snappy is an order of magnitude faster for most
# inputs, but the resulting compressed files are anywhere from 20% to 100%
# bigger.
#
# Home page: https://google.github.io/${PRGNAME}/
# Download:  https://github.com/google/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
