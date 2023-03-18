#! /bin/bash

PRGNAME="make"

### Make
# Утилита, автоматизирующая процесс преобразования файлов из одной формы в
# другую. Чаще всего это компиляция исходного кода в объектные файлы и
# последующая компоновка в исполняемые файлы или библиотеки.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# исправим проблему, обнаруженную в upstream
sed -e '/ifdef SIGPIPE/,+2 d'                     \
    -e '/undef  FATAL_SIG/i FATAL_SIG (SIGPIPE);' \
    -i src/main.c

# Make не будет ссылаться на библиотеки Guile, которые могут присутствовать в
# хост-системе, но не доступны в нашей временной среде
#    --without-guile
./configure             \
    --prefix=/usr       \
    --without-guile     \
    --host="${LFS_TGT}" \
    --build="$(build-aux/config.guess)" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"
