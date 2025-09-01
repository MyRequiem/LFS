#! /bin/bash

PRGNAME="diffutils"

### Diffutils
# Утилиты, которые показывают различия между файлами или каталогами

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure                       \
    --prefix=/usr                 \
    --host="${LFS_TGT}"           \
    gl_cv_func_strcasecmp_works=y \
    --build=$(./build-aux/config.guess) || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install
