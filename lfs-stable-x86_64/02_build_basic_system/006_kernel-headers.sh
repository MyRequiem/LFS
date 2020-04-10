#! /bin/bash

PRGNAME="kernel-headers"
ARCH_NAME="linux"

### Linux Headers (Linux kernel include files)

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/linux-headers.html

# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.5.15.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/

# На 05.04.20 версия ядра linux для LFS-stable - 5.5.3
# По рекомендации на странице
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html
# cледует использовать последнюю доступную версию ядра 5.5.x
# На 05.04.20 последняя версия ядра ветки 5.5.x это 5.5.15

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

make mrproper
make headers

find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include/* /usr/include

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
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

source "${ROOT}/write_to_var_log_packages.sh" \
    "$(pwd)/usr/include" "${PRGNAME}-${VERSION}"
