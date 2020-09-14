#! /bin/bash

PRGNAME="findutils"

### Findutils
# Пакет содержит программы для поиска файлов

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/findutils.html

# Home page: http://www.gnu.org/software/findutils/
# Download:  http://ftp.gnu.org/gnu/findutils/findutils-4.7.0.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
