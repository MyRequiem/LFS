#! /bin/bash

PRGNAME="xz"

### Xz
# Современная утилита для сжатия данных, обеспечивающая один из самых высоких
# уровней уменьшения размера файлов.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure                             \
    --prefix=/usr                       \
    --host="${LFS_TGT}"                 \
    --build="$(build-aux/config.guess)" \
    --disable-static                    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install

# удалим libtool архив (.la), т.к. он вреден для кросс-компиляции
rm -fv "${LFS}/usr/lib/liblzma.la"
