#! /bin/bash

PRGNAME="coreutils"

### Coreutils
# Утилиты для отображения и настройки основных характеристик системы: basename,
# cat, chmod, chown, chroot, cp, cut, date и т.д.

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/coreutils.html

# Home page: http://www.gnu.org/software/coreutils/
# Download:  http://ftp.gnu.org/gnu/coreutils/coreutils-8.31.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# собирать утилиту hostname - ее создание отключено по умолчанию
#    --enable-install-program=hostname
./configure         \
    --prefix=/tools \
    --enable-install-program=hostname || exit 1

make || make -j1 || exit 1
# запустим тесты
# параметр RUN_EXPENSIVE_TESTS=yes указывает тестовому набору выполнить
# некоторые дополнительные тесты
make RUN_EXPENSIVE_TESTS=yes check
# устанавливаем
make install
