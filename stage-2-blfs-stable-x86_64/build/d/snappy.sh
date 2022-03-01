#! /bin/bash

PRGNAME="snappy"

### snappy (A fast compressor/decompressor)
# Библиотека для быстрого сжатия и распаковки данных, написанная на C++ в
# Google на основе LZ77. Основной целью стало достижение высокой скорости
# сжатия, при этом задач наибольшего сжатия или совместимости с другими
# библиотеками не ставилось. Является хорошо переносимой, не использует
# ассемблерные вставки.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим ошибку, возникающую если установлен gtest
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-gtest.patch" || exit 1

# исправим ошибку сборки с gcc >= 10
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-attribute-always-inline.patch" || exit 1

mkdir -p build
cd build || exit 1

cmake                           \
  -DCMAKE_INSTALL_PREFIX=/usr   \
  -DCMAKE_BUILD_TYPE="Release"  \
  -DBUILD_SHARED_LIBS=ON        \
  -DSNAPPY_BUILD_TESTS=OFF      \
  -DSNAPPY_BUILD_BENCHMARKS=OFF \
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
# Home page: https://github.com/google/${PRGNAME}
# Download:  https://github.com/google/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
