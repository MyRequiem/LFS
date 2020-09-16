#! /bin/bash

PRGNAME="patch"

### Patch
# Программа для изменения или создания файлов путем применения файлов *.patch,
# обычно создаваемых программой diff

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/patch.html

# Home page: https://savannah.gnu.org/projects/patch/

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
