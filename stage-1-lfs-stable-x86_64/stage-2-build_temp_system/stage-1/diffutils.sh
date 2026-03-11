#! /bin/bash

PRGNAME="diffutils"

### Diffutils
# GNU Diffutils - это набор программ для сравнения файлов и папок, который
# находит различия между ними. Он позволяет быстро увидеть, что именно
# изменилось в тексте, и подготовить специальные файлы-патчи для
# автоматического обновления программ. Это незаменимый инструмент для
# программистов и системных администраторов при работе с конфигурациями и
# исходным кодом.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure                       \
    --prefix=/usr                 \
    --host="${LFS_TGT}"           \
    gl_cv_func_strcasecmp_works=y \
    --build=$(./build-aux/config.guess) || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install
