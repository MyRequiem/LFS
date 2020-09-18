#! /bin/bash

PRGNAME="file"

### File
# Утилита для определения типа файла

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/file.html

# Home page: https://www.darwinsys.com/file/

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure       \
    --prefix=/usr \
    --host="${LFS_TGT}" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
