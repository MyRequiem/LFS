#! /bin/bash

PRGNAME="findutils"

### Findutils
# Пакет содержит программы для поиска файлов

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/findutils.html

# Home page: http://www.gnu.org/software/findutils/
# Download:  http://ftp.gnu.org/gnu/findutils/findutils-4.6.0.tar.gz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# некоторые исправления для glibc-2.28
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
