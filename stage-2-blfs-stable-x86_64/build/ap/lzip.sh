#! /bin/bash

PRGNAME="lzip"

### Lzip (a lossless data compressor)
# Предоставляет алгорит сжатия данных без потерь с пользовательским
# интерфейсом, аналогичным из gzip или bzip2. Lzip распаковывает почти так же
# быстро, как gzip и сжимает лучше, чем bzip2, что делает его очень подходящим
# для распространения программного обеспечения и архивирование данных. Lzip -
# это чистая реализация алгоритма LZMA.

# нет в BLFS

# Home page: https://www.nongnu.org/lzip/lzip.html
# Download:  http://download.savannah.gnu.org/releases/lzip/lzip-1.21.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
make install
make install DESTDIR="${TMP_DIR}"

# документация
mkdir -pv "${DOCS}"
cp -va AUTHORS COPYING ChangeLog INSTALL NEWS README "${DOCS}"
cp -va AUTHORS COPYING ChangeLog INSTALL NEWS README "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a lossless data compressor)
#
# Lzip is a lossless data compressor with a user interface similar to the one
# of gzip or bzip2. Lzip decompresses almost as fast as gzip and compresses
# more than bzip2, which makes it well suited for software distribution and
# data archiving. Lzip is a clean implementation of the LZMA algorithm.
#
# Home page: https://www.nongnu.org/${PRGNAME}/${PRGNAME}.html
# Download:  http://download.savannah.gnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
