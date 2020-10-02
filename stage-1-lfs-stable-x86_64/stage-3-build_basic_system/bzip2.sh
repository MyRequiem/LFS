#! /bin/bash

PRGNAME="bzip2"

### Bzip2 (a block-sorting file compressor)
# Программы для сжатия и распаковки файлов. Сжатие текстовых файлов с помощью
# bzip2 дает гораздо лучший процент сжатия чем с традиционным Gzip.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{bin,lib}

# применим патч для установки документации
patch -Np1 --verbose \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-install_docs-1.patch" || exit 1

# обеспечим правильную установку путей для относительных символических ссылок
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile || exit 1

# man-страницы должны быть установлены в /usr/share/man
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile || exit 1

# пакет Bzip2 не содержит скрипта 'configure' и включает в себя два Makefile:
#    Makefile-libbz2_so    - для сборки shared библиотеки
#    Makefile              - для сборки static библиотеки
# нам нужны обе, поэтому будем компилировать в два этапа:
make -f Makefile-libbz2_so || make -j1 -f Makefile-libbz2_so || exit 1
make clean
make || make -j1 || exit 1

make PREFIX="${TMP_DIR}/usr" install

# установим
#    bzip2      в /bin
#    libbz2.so* в /lib
cp -v  bzip2-shared "${TMP_DIR}/bin/bzip2"
cp -av libbz2.so*   "${TMP_DIR}/lib"

rm -v "${TMP_DIR}/usr/bin"/{bunzip2,bzcat,bzip2}

# создадим необходимые ссылки
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
(
    # ссылка в /usr/lib/
    #    libbz2.so -> ../../lib/libbz2.so.${MAJ_VERSION}
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sv "../../lib/libbz2.so.${MAJ_VERSION}" libbz2.so

    # ссылки в /bin/
    #    bunzip2 -> bzip2
    #    bzcat   -> bzip2
    cd "${TMP_DIR}/bin" || exit 1
    ln -sv bzip2 bunzip2
    ln -sv bzip2 bzcat
)

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a block-sorting file compressor)
#
# The Bzip2 package contains programs for compressing and decompressing files.
# Bzip2 compresses files using the Burrows-Wheeler block sorting text
# compression algorithm, and Huffman coding. Compression is generally
# considerably better than that achieved by more conventional LZ77/LZ78-based
# compressors, and approaches the performance of the PPM family of statistical
# compressors.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}/
# Download:  https://www.sourceware.org/pub/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
