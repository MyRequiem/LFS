#! /bin/bash

PRGNAME="patch"

### Patch
# Программа для изменения или создания файлов путем применения файлов *.patch,
# обычно создаваемых программой diff

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/patch.html

# Home page: https://savannah.gnu.org/projects/patch/
# Download:  http://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
