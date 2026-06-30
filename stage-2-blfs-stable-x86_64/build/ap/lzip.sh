#! /bin/bash

PRGNAME="lzip"

### Lzip (a lossless data compressor)
# Мощный архиватор, который использует алгоритм LZMA для очень сильного сжатия
# данных. Часто применяется для долгосрочного хранения важных бэкапов с высокой
# степенью надежности.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a lossless data compressor)
#
# Lzip is a lossless data compressor with a user interface similar to the one
# of gzip or bzip2. Lzip decompresses almost as fast as gzip and compresses
# more than bzip2, which makes it well suited for software distribution and
# data archiving. Lzip is a clean implementation of the LZMA algorithm.
#
# Home page: https://www.nongnu.org/${PRGNAME}/${PRGNAME}.html
# Download:  https://download.savannah.nongnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
