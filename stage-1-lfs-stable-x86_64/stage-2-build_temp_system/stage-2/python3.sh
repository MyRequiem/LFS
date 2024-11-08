#! /bin/bash

PRGNAME="python3"
ARCH_NAME="Python"

### Python
# Язык программирования Python v3

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# не устанавливаем статические библиотеки
#    --enable-shared
# утилита pip - 'Python package installer' на данном этапе нам не нужна
#    --without-ensurepip
./configure         \
    --prefix=/usr   \
    --enable-shared \
    --without-ensurepip || exit 1

make || make -j1 || exit 1
make install
