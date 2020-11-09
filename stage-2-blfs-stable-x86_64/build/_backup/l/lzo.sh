#! /bin/bash

PRGNAME="lzo"

### LZO (LZO Compression Library)
# Библиотека сжатия данных без потерь, написанная на ANSI C. Предлагает
# довольно быстрое сжатие и очень быструю распаковку.

# http://www.linuxfromscratch.org/blfs/view/stable/general/lzo.html

# Home page: http://www.oberhumer.com/opensource/lzo/
# Download:  http://www.oberhumer.com/opensource/lzo/download/lzo-2.10.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --enable-shared  \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# проверить сборку
# make check

# полный набор тестов
# make test

make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (LZO Compression Library)
#
# LZO is a portable lossless data compression library written in ANSI C. It
# offers pretty fast compression and very fast decompression. This means it
# favors speed over compression ratio.
#
# Home page: http://www.oberhumer.com/opensource/${PRGNAME}/
# Download:  http://www.oberhumer.com/opensource/${PRGNAME}/download/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
