#! /bin/bash

PRGNAME="gzip"

### Gzip
# Программы для сжатия и распаковки файлов

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gzip.html

# Home page: http://www.gnu.org/software/gzip/
# Download:  http://ftp.gnu.org/gnu/gzip/gzip-1.10.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/bin"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# известно, что в среде LFS не проходят два теста: help-version и zmore
make check
make install
make install DESTDIR="${TMP_DIR}"

# переместим gzip из /usr/bin в /bin, т.к. этого требуют многие программы
mv -v /usr/bin/gzip /bin
mv -v "${TMP_DIR}/usr/bin/gzip" "${TMP_DIR}/bin"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (file compression utility)
#
# Package contains programs for compressing and decompressing files. Gzip
# reduces the size of the named files using Lempel-Ziv coding (LZ77). Whenever
# possible, each file is replaced by one with the extension .gz, while keeping
# the same ownership modes, access and modification times.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
