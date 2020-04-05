#! /bin/bash

PRGNAME="linux-headers"

### Linux Headers

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/linux-headers.html

# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.2.21.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/

# Версия ядра linux для LFS-9.0 - 5.2.8
# По рекомендации на странице
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html
# cледует использовать последнюю доступную версию ядра 5.2.x
# На 20.01.20 последняя версия ядра ветки 5.2.x это 5.2.21

ARCH_NAME="$(echo ${PRGNAME} | cut -d - -f 1)"
source "$(pwd)/check_environment.sh"                    || exit 1
source "$(pwd)/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# очищаем исходники ядра
make mrproper
# во время установки заголовков в указанную параметром INSTALL_HDR_PATH
# директорию, эта директория сначала полностью очищается. Поэтому будет
# правильнее установить заголовки во временную директорию, например
# ./tmp-linux-headers, а уже потом скопировать содержимое директории
# ./tmp-linux-headers/include/ в /tools/include
make INSTALL_HDR_PATH=./tmp-"${PRGNAME}" headers_install
cp -rv ./tmp-"${PRGNAME}"/include/* /tools/include
