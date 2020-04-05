#! /bin/bash

PRGNAME="binutils"

### Binutils
# Пакет содержит компоновщик, ассемблер и другие инструменты для работы с
# объектными файлами

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/binutils-pass2.html

# Home page: http://www.gnu.org/software/binutils/
# Download:  http://ftp.gnu.org/gnu/binutils/binutils-2.34.tar.xz

###
# Это второй проход binutils
###

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# документация Binutils рекомендует собирать binutils в отдельном каталоге для
# сборки
mkdir build
cd build || exit 1

# установка этих переменных гарантирует, что система сборки использует
# кросс-компилятор и связанные инструменты вместо инструментов хост-системы
CC="${LFS_TGT}-gcc"            \
AR="${LFS_TGT}-ar"             \
RANLIB="${LFS_TGT}-ranlib"     \
../configure                   \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot || exit 1

make || make -j1 || exit 1
make install

# теперь подготовим компоновщик к этапу "повторной настройки", которая
# понадобится позже. Удалим все скомпилированные файлы в подкаталоге ld
make -C ld clean
# указываем путь поиска библиотек по умолчанию для компоновщика
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin
