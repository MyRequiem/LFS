#! /bin/bash

PRGNAME="m4"

### M4
# Пакет M4 содержит макропроцессор

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/m4.html

# Home page: http://www.gnu.org/software/m4/
# Download:  http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# внесем исправления, необходимые для glibc-2.28:
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1

# запустим тесты
make check
# установка
make install
