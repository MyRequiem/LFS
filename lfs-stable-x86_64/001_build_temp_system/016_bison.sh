#! /bin/bash

PRGNAME="bison"

### Bison
# Пакет предназначен для автоматического создания синтаксических анализаторов

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/bison.html

# Home page: http://www.gnu.org/software/bison/
# Download:  http://ftp.gnu.org/gnu/bison/bison-3.4.1.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
