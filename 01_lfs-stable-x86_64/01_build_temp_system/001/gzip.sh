#! /bin/bash

PRGNAME="gzip"

### Gzip
# Программы для сжатия и распаковки файлов

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gzip.html

# Home page: http://www.gnu.org/software/gzip/

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure       \
    --prefix=/usr \
    --host="${LFS_TGT}" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"

# переместим утилиту gzip из /mnt/lfs/usr/bin/ в /mnt/lfs/bin/
mv -v "${LFS}/usr/bin/gzip" "${LFS}/bin"
