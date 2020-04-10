#! /bin/bash

PRGNAME="bzip2"

### Bzip2 (a block-sorting file compressor)
# Программы для сжатия и распаковки файлов. Сжатие текстовых файлов с помощью
# bzip2 дает гораздо лучший процент сжатия чем с традиционным Gzip.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/bzip2.html

# Home page: https://sourceforge.net/projects/bzip2/
# Download:  https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{bin,lib}

# применим патч для установки документации
patch -Np1 --verbose \
    -i "/sources/${PRGNAME}-${VERSION}-install_docs-1.patch" || exit 1

# обеспечим правильную установку путей для относительных символических ссылок
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile

# man-страницы должны быть установлены в /usr/share/man
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile

### подготовка к сборке
# сначала соберем динамическую библиотеку libbz2.so.${VERSION} и связанную с
# ней утилиту bzip2-shared
make -f Makefile-libbz2_so || exit 1
make clean

# собираем утилиты bzip2 и bzip2recover и устанавливаем пакет
make || exit 1
make PREFIX=/usr install
make PREFIX="${TMP_DIR}/usr" install

# установим bzip2 в /bin
cp -v bzip2-shared /bin/bzip2
cp -v bzip2-shared "${TMP_DIR}/bin/bzip2"

# копируем libbz2.so* в /lib
cp -av libbz2.so* /lib
cp -av libbz2.so* "${TMP_DIR}/lib"

# создадим необходимые символические ссылки
# ссылка в /usr/lib/
# libbz2.so -> ../../lib/libbz2.so.1.0
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sv ../../lib/libbz2.so.1.0 libbz2.so
)

# ссылки в /bin/
# bunzip2 -> bzip2
# bzcat -> bzip2
rm -vf /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

rm -fv "${TMP_DIR}/usr/bin"/{bunzip2,bzcat,bzip2}
(
    cd "${TMP_DIR}/bin" || exit 1
    ln -sv bzip2 bunzip2
    ln -sv bzip2 bzcat
)

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

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
