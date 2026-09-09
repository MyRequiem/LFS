#! /bin/bash

PRGNAME="kernel-headers"
ARCH_NAME="linux"

### Linux Headers
# Набор заголовочных файлов с описанием функций ядра, необходимых программистам
# для сборки системных программ, библиотек, драйверов и др.

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

# удалим ненужные файлы и скопируем заголовки в $LFS/usr/include/
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include "${LFS}/usr"
