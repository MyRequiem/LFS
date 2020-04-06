#! /bin/bash

PRGNAME="xz"

### Xz
# Программы для сжатия и распаковки файлов (lzma и более новых форматов сжатия
# xz). Сжатие текстовых файлов с помощью xz дает лучший процент сжатия, чем при
# использовании традиционных команд gzip или bzip2.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/xz.html

# Home page: https://tukaani.org/xz
# Download:  https://tukaani.org/xz/xz-5.2.4.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
