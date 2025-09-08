#! /bin/bash

PRGNAME="kernel-headers"
ARCH_NAME="linux"
VERSION="$1"

### Linux Headers (Linux kernel include files)
# заголовочные файлы ядра

###
# WARNINIG !!!
# удалять пакет перед переустановкой/обновлением нельзя, иначе собрать его
# заново будет невозможно
###

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

if [ -z "${VERSION}" ]; then
    echo "Usage: $0 <kernel-version>"
    exit 1
fi

SRC_DIR="/usr/src/${ARCH_NAME}-${VERSION}"
if ! [ -d "${SRC_DIR}" ]; then
    echo "Directory ${SRC_DIR} not found !!!"
    echo "You need to install 'kernel-source-${VERSION}' package"
    exit 1
fi

cd "${SRC_DIR}" || exit 1

# очищаем дерево исходников ядра
make mrproper || exit 1

# извлечем заголовки из исходного кода ядра в <kernel_src_dir>/usr/include/
# Рекомендованный
#    make target "headers_install"
# не может быть использован, поскольку он требует rsync, который
# устанавливается в BLFS
make headers || exit 1

cp -r usr/{include,include_orig}

# удалим ненужные файлы и скопируем заголовки в /usr/include/
find usr/include/ -type f ! -name '*.h' -delete
cp -rv usr/include /usr

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

rm -rf usr/include
mv usr/{include_orig,include}
