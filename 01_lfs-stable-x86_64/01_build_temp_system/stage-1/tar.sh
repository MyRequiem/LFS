#! /bin/bash

PRGNAME="tar"

### Tar
# Программа архивации файлов и каталогов

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/tar.html

# Home page: http://www.gnu.org/software/tar/

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure             \
    --prefix=/usr       \
    --bindir=/bin       \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
