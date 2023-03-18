#! /bin/bash

PRGNAME="findutils"

### Findutils
# Пакет содержит программы для поиска файлов

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure                         \
    --prefix=/usr                   \
    --host="${LFS_TGT}"             \
    --localstatedir=/var/lib/locate \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
