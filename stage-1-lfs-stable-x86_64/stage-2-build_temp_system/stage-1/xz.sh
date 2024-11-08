#! /bin/bash

PRGNAME="xz"

### Xz
# Программы для сжатия и распаковки файлов (lzma и более новых форматов сжатия
# xz). Сжатие текстовых файлов с помощью xz дает лучший процент сжатия, чем при
# использовании традиционных команд gzip или bzip2.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure                             \
    --prefix=/usr                       \
    --host="${LFS_TGT}"                 \
    --disable-static                    \
    --build="$(build-aux/config.guess)" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install

# удалим libtool архив (.la), т.к. он вреден для кросс-компиляции
rm -fv "${LFS}/usr/lib/liblzma.la"
