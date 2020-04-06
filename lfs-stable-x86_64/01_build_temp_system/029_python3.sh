#! /bin/bash

PRGNAME="python3"
echo "Building ${PRGNAME}..."

### Python
# Язык программирования Python 3

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/Python.html

# Home page: https://www.python.org/
# Download:  https://www.python.org/ftp/python/3.8.1/Python-3.8.1.tar.xz

source "$(pwd)/check_environment.sh"              || exit 1
source "$(pwd)/unpack_source_archive.sh" "Python" || exit 1

# сначала создается интерпретатор python3, а затем некоторые стандартные модули
# Python. Основной сценарий для создания модулей написан на Python и использует
# жестко заданные пути к каталогам на хосте /usr/include и /usr/lib Чтобы
# предотвратить их использование, выполним:
sed -i '/def add_multiarch_paths/a \        return' setup.py

# не создаем утилиту 'pip', которая не требуется на данном этапе
#    --without-ensurepip
./configure         \
    --prefix=/tools \
    --without-ensurepip || exit 1

make || make -j1 || exit 1
# набор тестов требует TK и X Window System, которые не доступны в нашей
# временной системе, поэтому сразу устанавливаем пакет
make install
