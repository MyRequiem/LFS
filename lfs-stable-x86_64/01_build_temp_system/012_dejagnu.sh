#! /bin/bash

PRGNAME="dejagnu"

### DejaGNU
# Пакет DejaGNU содержит платформу для тестирования других программ

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/dejagnu.html

# Home page: http://www.gnu.org/software/dejagnu/
# Download:  http://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.2.tar.gz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/tools || exit 1

# сборка и установка пакета
make install
# проверим результаты сборки
make check
