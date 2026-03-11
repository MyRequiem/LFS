#! /bin/bash

PRGNAME="findutils"

### Findutils
# Мощные инструменты для поиска файлов в системе по их имени, дате создания,
# размеру или другим параметрам.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure                         \
    --prefix=/usr                   \
    --localstatedir=/var/lib/locate \
    --host="${LFS_TGT}"             \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install
