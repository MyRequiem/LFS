#! /bin/bash

PRGNAME="gawk"

### Gawk
# Язык обработки текстовых строк, позволяющий быстро находить и изменять
# информацию в больших списках или логах системы.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# дополнительные утилиты из extras не устанавливаем
sed -i 's/extras//' Makefile.in

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install
