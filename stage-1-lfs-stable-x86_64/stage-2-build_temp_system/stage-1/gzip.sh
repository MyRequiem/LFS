#! /bin/bash

PRGNAME="gzip"

### Gzip
# Стандартная утилита для быстрого сжатия и распаковки файлов, широко
# применяемая для хранения документации и архивов.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure       \
    --prefix=/usr \
    --host="${LFS_TGT}" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install
