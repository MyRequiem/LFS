#! /bin/bash

PRGNAME="gzip"

### Grep
# Программы для сжатия и распаковки файлов

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gzip.html

# Home page: http://www.gnu.org/software/gzip/
# Download:  http://ftp.gnu.org/gnu/gzip/gzip-1.10.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
