#! /bin/bash

PRGNAME="Python"

### Python
# Язык программирования Python 3

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/Python.html

# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/3.7.4/Python-3.7.4.tar.xz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# сначала создается интерпретатор python3, а затем некоторые стандартные модули
# Python. Основной сценарий для создания модулей написан на Python и использует
# жестко заданные пути к каталогам на хосте /usr/include и /usr/lib Чтобы
# предотвратить их использование, выполним:
sed -i '/def add_multiarch_paths/a \        return' setup.py

# этот параметр отключает установщик пакета Python, который не требуется на
# данном этапе.
#    --without-ensurepip
./configure         \
    --prefix=/tools \
    --without-ensurepip || exit 1

make || make -j1 || exit 1
# набор тестов требует TK и X Window System, которые еще не установлены,
# поэтому сразу устанавливаем пакет
make install
