#! /bin/bash

PRGNAME="lz4"

### Lz4 (fast lossless compression algorithm)
# Алгоритм сжатия без потерь, обеспечивающий скорость сжатия > 500 МБ/с на одно
# ядро процессора. Отличается чрезвычайно быстрым декодером со скоростью в
# несколько ГБ/с на ядро.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

make BUILD_STATIC=no PREFIX=/usr || exit 1
# make -j1 check
make BUILD_STATIC=no PREFIX=/usr install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (fast lossless compression algorithm)
#
# LZ4 is a lossless compression algorithm, providing compression speed > 500
# MB/s per core, scalable with multi-cores CPU. It features an extremely fast
# decoder, with speed in multiple GB/s per core, typically reaching RAM speed
# limits on multi-core systems.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
