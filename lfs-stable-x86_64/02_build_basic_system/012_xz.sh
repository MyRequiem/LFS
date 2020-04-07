#! /bin/bash

PRGNAME="xz"

### Xz
# Программы для сжатия и распаковки файлов (lzma и более новых форматов сжатия
# xz). Сжатие текстовых файлов с помощью xz дает лучший процент сжатия, чем при
# использовании традиционных команд gzip или bzip2.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/xz.html

# Home page: https://tukaani.org/xz
# Download:  https://tukaani.org/xz/xz-5.2.4.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{bin,lib}

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make check
make install
make install DESTDIR="${TMP_DIR}"

# переместим некоторые утилиты из /usr/bin в /bin
mv -v /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v "${TMP_DIR}/usr/bin"/{lzma,unlzma,lzcat,xz,unxz,xzcat} "${TMP_DIR}/bin"

# библиотеку liblzma.so необходимо переместить из /usr/lib в /lib
mv -v /usr/lib/liblzma.so.* /lib
mv -v "${TMP_DIR}/usr/lib"/liblzma.so.* "${TMP_DIR}/lib"

# воссоздадим ссылку liblzma.so в /usr/lib
# liblzma.so -> ../../lib/liblzma.so.${VERSION}
ln -svf "../../lib/$(readlink /usr/lib/liblzma.so)" /usr/lib/liblzma.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -svf "../../lib/$(readlink liblzma.so)" liblzma.so
)

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
# Download:  https://tukaani.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
