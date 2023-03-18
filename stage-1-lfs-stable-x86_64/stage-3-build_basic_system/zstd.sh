#! /bin/bash

PRGNAME="zstd"

### Zstandard (fast lossless real-time compression algorithm)
# Real-time алгоритм сжатия, обеспечивающий относительно высокую степень сжатия
# и поддерживается очень быстрым декодером

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

make prefix=/usr || make -j1  prefix=/usr || exit 1
# make check
make prefix=/usr install DESTDIR="${TMP_DIR}"

# удалим статическую библиотеку
rm -fv "${TMP_DIR}/usr/lib/libzstd.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (fast lossless real-time compression algorithm)
#
# Zstandard is a real-time compression algorithm, providing high compression
# ratios. It offers a very wide range of compression/speed trade-off, while
# being backed by a very fast decoder. It also offers a special mode for small
# data, called dictionary compression, and can create dictionaries from any
# sample set.
#
# Home page: https://facebook.github.io/${PRGNAME}/
# Download:  https://github.com/facebook/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
