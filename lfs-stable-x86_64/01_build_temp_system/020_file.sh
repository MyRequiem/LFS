#! /bin/bash

PRGNAME="file"

### File
# Утилита для определения типа файла

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/file.html

# Home page: https://www.darwinsys.com/file/
# Download:  ftp://ftp.astron.com/pub/file/file-5.38.tar.gz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
