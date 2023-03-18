#! /bin/bash

PRGNAME="grep"

### Grep
# Программы для поиска по файлам

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
