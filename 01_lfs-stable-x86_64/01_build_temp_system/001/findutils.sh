#! /bin/bash

PRGNAME="findutils"

### Findutils
# Пакет содержит программы для поиска файлов

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/findutils.html

# Home page: http://www.gnu.org/software/findutils/

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"

# переместим утилиту 'find' из /mnt/lfs/usr/bin/ в /mnt/lfs/bin/
mv -v "${LFS}/usr/bin/find" "${LFS}/bin/"
sed -i 's|find:=${BINDIR}|find:=/bin|' "${LFS}/usr/bin/updatedb"
