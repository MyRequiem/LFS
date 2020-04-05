#! /bin/bash

PRGNAME="kernel-headers"
ARCH_NAME="linux"

### Linux Headers

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/linux-headers.html

# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.2.21.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/

# Версия ядра linux для LFS-9.0 - 5.2.8
# По рекомендации на странице
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html
# cледует использовать последнюю доступную версию ядра 5.2.x
# На 20.01.20 последняя версия ядра ветки 5.2.x это 5.2.21

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# очищаем исходники ядра
make mrproper
# во время установки заголовков в указанную параметром INSTALL_HDR_PATH
# директорию, эта директория сначала полностью очищается. Поэтому будет
# правильнее установить заголовки во временную директорию, например
# ./lfs-linux-headers, а уже потом скопировать содержимое директории
# ./lfs-linux-headers/include/ в /tools/include
TMP_DIR="lfs-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make INSTALL_HDR_PATH="${TMP_DIR}" headers_install
# удаляем не нужные файлы .install и install.cmd
find "${TMP_DIR}/include" \( -name .install -o -name ..install.cmd \) -delete
cp -rv "${TMP_DIR}/include"/* /usr/include

mkdir -p "${TMP_DIR}/usr"
mv "${TMP_DIR}/include" "${TMP_DIR}/usr"

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
    "$(pwd)/${TMP_DIR}" "${PRGNAME}-${VERSION}"
