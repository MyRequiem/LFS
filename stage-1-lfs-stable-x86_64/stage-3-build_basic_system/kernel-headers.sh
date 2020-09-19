#! /bin/bash

PRGNAME="kernel-headers"
ARCH_NAME="linux"

### Linux Headers (Linux kernel include files)

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/linux-headers.html

# Home page:    https://www.kernel.org/
# Download:     https://mirrors.edge.kernel.org/pub/linux/kernel/v5.x/linux-5.8.9.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/

# cледует использовать последнюю доступную стабильную версию ядра ветки v5.x
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# очищаем дерево исходников ядра
make mrproper

# извлечем заголовки из исходного кода ядра в ./usr/include/
# Рекомендованный
#    make target "headers_install"
# не может быть использован, поскольку он требует rsync, который пока не
# установлен в LFS системе
make headers

# удалим не нужные файлы и скопируем заголовки в /usr/include/
find usr/include -name '.*' -delete
rm -f usr/include/Makefile
cp -rv usr/include/* /usr/include

LOG="/var/log/packages/${PRGNAME}-${VERSION}"
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "${LOG}"
# Package: ${PRGNAME} (Linux kernel include files)
#
# The Linux API Headers expose the kernel's API (include files from the Linux
# kernel) for use by Glibc. You'll need these to compile most system software
# for Linux.
#
# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v${MAJ_VERSION}.x/${ARCH_NAME}-${VERSION}.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/
#
EOF

# пишем список установленных файлов в лог
find usr/include | sort >> "${LOG}"
# добавим слеши в начале путей (usr/include/... -> /usr/include/...)
sed -i 's/^usr\//\/usr\//' "${LOG}"
# удалим пустые строки в файле
sed -i '/^$/d' "${LOG}"
