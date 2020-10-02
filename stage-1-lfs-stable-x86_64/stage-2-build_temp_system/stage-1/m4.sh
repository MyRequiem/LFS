#! /bin/bash

PRGNAME="m4"

### M4
# Пакет M4 содержит макропроцессор

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# внесем исправления, необходимые для glibc-2.28
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c || exit 1
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

./configure             \
    --prefix=/usr       \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
