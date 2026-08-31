#! /bin/bash

PRGNAME="zlib"

### Zlib
# Популярная многопоточная библиотека для сжатия данных в оперативной памяти,
# которую используют тысячи других программ для скорости и экономии места.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
make install
rm -fv /usr/lib/libz.a
