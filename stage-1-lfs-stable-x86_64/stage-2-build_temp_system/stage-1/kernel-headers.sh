#! /bin/bash

PRGNAME="kernel-headers"
echo "Building ${PRGNAME}"
ARCH_NAME="linux"

### Linux Headers
# Заголовочные файлы ядра linux для использования API ядра при сборке Glibc

source "$(pwd)/check_environment.sh"                    || exit 1
source "$(pwd)/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# очищаем дерево исходников ядра
make mrproper || exit 1

# извлечем заголовки из исходного кода ядра в ./usr/include/
# Рекомендованный
#    make target "headers_install"
# не может быть использован, поскольку он требует rsync, который пока не
# установлен в LFS системе
make headers || exit 1

# удалим не нужные файлы и скопируем заголовки в $LFS/usr/include/
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include "${LFS}/usr"
