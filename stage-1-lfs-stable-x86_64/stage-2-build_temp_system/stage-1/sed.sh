#! /bin/bash

PRGNAME="sed"

### Sed
# Потоковый редактор

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/sed.html

# Home page: http://www.gnu.org/software/sed/

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --bindir=/bin || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
