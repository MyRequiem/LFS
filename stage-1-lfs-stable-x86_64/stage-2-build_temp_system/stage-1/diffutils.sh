#! /bin/bash

PRGNAME="diffutils"

### Diffutils
# Утилиты, которые показывают различия между файлами или каталогами

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure       \
    --prefix=/usr \
    --host="${LFS_TGT}" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
