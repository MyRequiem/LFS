#! /bin/bash

PRGNAME="kernel-source"
ARCH_NAME="linux"

### Linux kernel source (Source code for Linus Torvalds Linux kernel)
# Исходный код ядра linux

# LFS рекомендует использовать последнюю стабильную версию ядра.

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

SOURCES="/sources"
ARCH=$(find "${SOURCES}" -type f -name "${ARCH_NAME}-*.tar.?z*" \
    2>/dev/null | head -n 1)

if [ -z "${ARCH}" ]; then
    echo -n "Linux kernel source archive not found in ${SOURCES} directory"
    exit 1
fi

VERSION="$(echo "${ARCH}" | rev | cut -d / -f 1 | cut -d . -f 3- | \
    cut -d - -f 1 | rev)"

USR_SRC="/usr/src"
cd "${USR_SRC}" || exit 1
rm -rf "${ARCH_NAME}-${VERSION}"

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# очистим дерево исходников
echo -e "\n# make mrproper..."
make mrproper || exit 1

# ссылка в /usr/src
#    linux -> linux-${VERSION}
cd /usr/src || exit 1
ln -svf "linux-${VERSION}" linux

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
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/
#
/usr/src/linux
EOF

find "${USR_SRC}/${ARCH_NAME}-${VERSION}" | sort >> "${TARGET}"
# удалим пустые строки
sed -i '/^$/d' "${TARGET}"
