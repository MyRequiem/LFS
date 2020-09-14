#! /bin/bash

PRGNAME="grep"

### Grep
# Программы для поиска по файлам

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/grep.html

# Home page: http://www.gnu.org/software/grep/
# Download:  http://ftp.gnu.org/gnu/grep/grep-3.4.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
