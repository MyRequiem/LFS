#! /bin/bash

PRGNAME="sed"

### Sed
# Потоковый редактор

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/sed.html

# Home page: http://www.gnu.org/software/sed/
# Download:  http://ftp.gnu.org/gnu/sed/sed-4.7.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
