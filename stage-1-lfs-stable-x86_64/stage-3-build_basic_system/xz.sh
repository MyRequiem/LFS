#! /bin/bash

PRGNAME="xz"

### Xz (compression utility based on the LZMA algorithm)
# Программы для сжатия и распаковки файлов (lzma и более новых форматов сжатия
# xz). Сжатие текстовых файлов с помощью xz дает лучший процент сжатия, чем при
# использовании традиционных команд gzip или bzip2.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (compression utility based on the LZMA algorithm)
#
# LZMA is a general purpose compression algorithm designed by Igor Pavlov as
# part of 7-Zip. Xz package contains programs for compressing and decompressing
# files provides capabilities for the lzma and the newer xz compression
# formats. It provides high compression ratio while keeping the decompression
# speed fast (a better compression percentage than with the traditional gzip or
# bzip2 commands). XZ Utils are an attempt to make LZMA compression easy to use
# on free (as in freedom) operating systems.
#
# Home page: https://tukaani.org/${PRGNAME}
# Download:  https://github.com/tukaani-project/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
