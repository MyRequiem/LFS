#! /bin/bash

PRGNAME="glibc"

### Glibc
# Пакет Glibc содержит основную библиотеку C. Эта библиотека предоставляет
# основные процедуры для выделения памяти, поиска в каталогах, открытия и
# закрытия файлов, чтения и записи файлов, обработки строк, сопоставления с
# образцом, арифметики и так далее.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/glibc.html

# Home page: http://www.gnu.org/software/libc/
# Download:  http://ftp.gnu.org/gnu/glibc/glibc-2.31.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# документация glibc рекомендует собирать glibc в отдельном каталоге для сборки
mkdir build
cd build || exit 1

../configure                             \
    --prefix=/tools                      \
    --host="${LFS_TGT}"                  \
    --build="$(../scripts/config.guess)" \
    --enable-kernel=3.2                  \
    --with-headers=/tools/include || exit 1

make || make -j1 || exit 1
make install
