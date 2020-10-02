#! /bin/bash

PRGNAME="xz"

### Xz
# Программы для сжатия и распаковки файлов (lzma и более новых форматов сжатия
# xz). Сжатие текстовых файлов с помощью xz дает лучший процент сжатия, чем при
# использовании традиционных команд gzip или bzip2.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure                             \
    --prefix=/usr                       \
    --host="${LFS_TGT}"                 \
    --disable-static                    \
    --build="$(build-aux/config.guess)" \
    --docdir="/usr/share/doc/xz-${VERSION}" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"

# переместим утилиты из /mnt/lfs/usr/bin/ в /mnt/lfs/bin/
mv -v "${LFS}/usr/bin"/{lzma,unlzma,lzcat,xz,unxz,xzcat}  "${LFS}/bin"
# переместим библиотеки из /mnt/lfs/usr/lib/ в /mnt/lfs/lib/
mv -v "${LFS}/usr/lib/liblzma.so."* "${LFS}/lib"
# воссоздадим ссылку liblzma.so в /mnt/lfs/usr/lib/, которая теперь битая
#    /mnt/lfs/usr/lib/liblzma.so -> ../../lib/liblzma.so.x.x.x
ln -svf "../../lib/$(readlink "${LFS}/usr/lib/liblzma.so")" \
    "${LFS}/usr/lib/liblzma.so"
