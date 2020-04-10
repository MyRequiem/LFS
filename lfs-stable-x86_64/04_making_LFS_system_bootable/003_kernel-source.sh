#! /bin/bash

PRGNAME="kernel-source"
ARCH_NAME="linux"

### Linux kernel source (Source code for Linus Torvalds Linux kernel)
# Исходный код ядра linux

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/kernel.html

# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.5.15.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/

# На 05.04.20 версия ядра linux для LFS-stable - 5.5.3
# По рекомендации на странице
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html
# cледует использовать последнюю доступную версию ядра 5.5.x
# На 05.04.20 последняя версия ядра ветки 5.5.x это 5.5.15

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

ROOT_SRC="/root/srс"
mkdir -pv "${ROOT_SRC}"

# архив с исходным кодом лежит в /sources или /root/srс
SOURCES="/sources"
ARCH=$(find "${SOURCES}" -type f -name "${ARCH_NAME}-*.tar.?z*" \
    2>/dev/null | head -n 1)

if [ -z "${ARCH}" ]; then
    SOURCES="${ROOT_SRC}"
    ARCH=$(find "${SOURCES}" -type f -name "${ARCH_NAME}-*.tar.?z*" \
        2>/dev/null | head -n 1)
fi

if [ -z "${ARCH}" ]; then
    echo -n "Linux kernel source archive not found in "
    echo "/source and /root/src directories"
    exit 1
fi

VERSION="$(echo "${ARCH}" | rev | cut -d / -f 1 | cut -d . -f 3- | \
    cut -d - -f 1 | rev)"

cd /usr/src || exit 1
rm -rf "${ARCH_NAME}-${VERSION}"

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

# очистим дерево исходников
echo -e "\n# make mrproper..."
make mrproper

TARGET="/var/log/packages/${PRGNAME}-${VERSION}"
MAJ_VER="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "${TARGET}"
# Package: ${PRGNAME} (Source code for Linus Torvalds Linux kernel)
#
# Source code for Linus Torvalds Linux kernel
# This is the complete and unmodified source code for the Linux kernel
#
# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v${MAJ_VER}.x/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

find "/usr/src/${ARCH_NAME}-${VERSION}" | sort >> "${TARGET}"
# удалим пустые строки
sed -i '/^$/d' "${TARGET}"
