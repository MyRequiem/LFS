#! /bin/bash

PRGNAME="tar"

### Tar
# Программа архивации файлов и каталогов

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/tar.html

# Home page: http://www.gnu.org/software/tar/
# Download:  http://ftp.gnu.org/gnu/tar/tar-1.32.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
