#! /bin/bash

PRGNAME="diffutils"

### Diffutils
# Утилиты, которые показывают различия между файлами или каталогами

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/diffutils.html

# Home page: http://www.gnu.org/software/diffutils/
# Download:  http://ftp.gnu.org/gnu/diffutils/diffutils-3.7.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
