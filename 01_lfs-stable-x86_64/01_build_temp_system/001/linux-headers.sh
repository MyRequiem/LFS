#! /bin/bash

PRGNAME="linux-headers"

### Linux Headers

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html

# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.5.15.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/

# На 05.04.20 версия ядра linux для LFS-stable - 5.5.3
# По рекомендации на странице
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html
# cледует использовать последнюю доступную версию ядра 5.5.x
# На 05.04.20 последняя версия ядра ветки 5.5.x это 5.5.15

ARCH_NAME="$(echo ${PRGNAME} | cut -d - -f 1)"
source "$(pwd)/check_environment.sh"                    || exit 1
source "$(pwd)/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# очищаем дерево исходников ядра
make mrproper

# извлечем заголовки из исходного кода ядра. Рекомендованный
#    make target "headers_install"
# не может быть использован, поскольку он требует rsync, который пока не
# установлен в LFS системе. Заголовки сначала помещаются в ./usr/include/, а
# затем мы их копируем в /tools/include/
make headers
cp -vr usr/include/* /tools/include/
