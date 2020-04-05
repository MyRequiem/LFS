#! /bin/bash

PRGNAME="texinfo"

### Texinfo
# Программы для чтения, записи и конвертации страниц info

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/texinfo.html

# Home page: http://www.gnu.org/software/texinfo/
# Download: http://ftp.gnu.org/gnu/texinfo/texinfo-6.6.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# в процессе конфигурации выполняется тест, который выдает ошибку для
# TestXS_la-TestXS.lo. Эта ошибка на данном этапе должна игнорироваться
./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1
make check
make install
