#! /bin/bash

PRGNAME="bzip2"

### Bzip2
# Программы для сжатия и распаковки файлов

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/bzip2.html

# Home page: https://sourceforge.net/projects/bzip2/
# Download:  https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

make || make -j1 || exit 1
make PREFIX=/tools install
