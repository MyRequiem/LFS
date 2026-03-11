#! /bin/bash

PRGNAME="patch"

### Patch
# Программа для автоматического внесения изменений в текстовые файлы на основе
# специальных файлов различий (.patch, .diff) обычно создаваемых утилитой diff

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install
