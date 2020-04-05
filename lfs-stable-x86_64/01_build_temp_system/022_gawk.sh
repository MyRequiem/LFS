#! /bin/bash

PRGNAME="gawk"

### Gawk
# Программы для работы с текстовыми файлами

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/gawk.html

# Home page: http://www.gnu.org/software/gawk/
# Download:  http://ftp.gnu.org/gnu/gawk/gawk-5.0.1.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
