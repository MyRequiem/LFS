#! /bin/bash

PRGNAME="gawk"

### Gawk
# Программы для работы с текстовыми файлами

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# дополнительные утилиты из extras не устанавливаем
sed -i 's/extras//' Makefile.in

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(./config.guess)" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
