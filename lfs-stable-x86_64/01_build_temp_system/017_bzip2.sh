#! /bin/bash

PRGNAME="bzip2"

### Bzip2
# Программы для сжатия и распаковки файлов

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/bzip2.html

# Home page: https://sourceforge.net/projects/bzip2/
# Download:  https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# пакет Bzip2 не содержит скрипта 'configure' и включает в себя два Makefile:
#    Makefile-libbz2_so    - для сборки shared библиотеки
#    Makefile              - для сборки static библиотеки
#
# Нам нужны обе, поэтому будем компилировать в два этапа:
make -f Makefile-libbz2_so || exit 1
make clean
make || exit 1

make PREFIX=/tools install

cp -v  bzip2-shared  /tools/bin/bzip2
cp -av libbz2.so*    /tools/lib
ln -sv libbz2.so.1.0 /tools/lib/libbz2.so
