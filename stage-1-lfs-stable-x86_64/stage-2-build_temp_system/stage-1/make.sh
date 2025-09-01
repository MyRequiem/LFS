#! /bin/bash

PRGNAME="make"

### Make
# Утилита, автоматизирующая процесс преобразования файлов из одной формы в
# другую. Чаще всего это компиляция исходного кода в объектные файлы и
# последующая компоновка в исполняемые файлы или библиотеки.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install
