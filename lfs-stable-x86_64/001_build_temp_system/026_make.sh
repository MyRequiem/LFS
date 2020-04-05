#! /bin/bash

PRGNAME="make"

### Make
# Программы для компиляции

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/make.html

# Home page: http://www.gnu.org/software/make/
# Download:  http://ftp.gnu.org/gnu/make/make-4.2.1.tar.gz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# обойдем ошибку, вызванную glibc-2.27 и более поздними версиями
sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c

# Make не будет ссылаться на библиотеки Guile, которые могут присутствовать в
# хост-системе, но пока не доступны в нашей временной среде
#    --without-guile
./configure         \
    --prefix=/tools \
    --without-guile || exit 1

make || make -j1 || exit 1
make check
make install
