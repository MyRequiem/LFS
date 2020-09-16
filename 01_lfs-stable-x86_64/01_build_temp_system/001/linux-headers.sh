#! /bin/bash

PRGNAME="linux-headers"
ARCH_NAME="$(echo ${PRGNAME} | cut -d - -f 1)"

### Linux Headers
# Заголовочные файлы ядра linux для использования API ядра при сборке Glibc

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html

# Home page: https://www.kernel.org/

# cледует использовать последнюю доступную стабильную версию ядра ветки v5.x
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html

source "$(pwd)/check_environment.sh"                    || exit 1
source "$(pwd)/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# очищаем дерево исходников ядра
make mrproper

# извлечем заголовки из исходного кода ядра в ./usr/include/
# Рекомендованный
#    make target "headers_install"
# не может быть использован, поскольку он требует rsync, который пока не
# установлен в LFS системе
make headers

# удалим не нужные файлы и скопируем заголовки в $LFS/tools/include/
find usr/include -name '.*' -delete
rm -f usr/include/Makefile
cp -rv usr/include "${LFS}/usr"
