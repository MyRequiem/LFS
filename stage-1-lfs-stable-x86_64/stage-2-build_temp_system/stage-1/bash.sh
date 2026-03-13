#! /bin/bash

PRGNAME="bash"

### Bash
# Bourne Again SHell - это основная программа для взаимодействия пользователя с
# системой через командную строку в Linux. Она служит командным
# интерпретатором, который понимает ваши текстовые команды, запускает нужные
# программы и позволяет автоматизировать задачи с помощью скриптов. По сути,
# это стандартный «пульт управления» и фундамент для работы большинства
# инструментов в операционной системе.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# опция отключает использование функции выделения памяти (malloc) Bash,
# которая, как известно, вызывает ошибки сегментации. Теперь Bash будет
# использовать функции malloc из Glibc, которые более стабильны
#    --without-bash-malloc
./configure                              \
    --prefix=/usr                        \
    --build="$(sh support/config.guess)" \
    --host="${LFS_TGT}"                  \
    --without-bash-malloc || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install

# создадим ссылку в ${LFS}/usr/bin/
#    sh -> bash
ln -svf bash "${LFS}/usr/bin/sh"
