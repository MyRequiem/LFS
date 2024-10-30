#! /bin/bash

PRGNAME="kernel-headers"
ARCH_NAME="linux"

### Linux Headers (Linux kernel include files)

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# очищаем дерево исходников ядра
make mrproper || exit 1

# извлечем заголовки из исходного кода ядра в ./usr/include/
# Рекомендованный
#    make target "headers_install"
# не может быть использован, поскольку он требует rsync, который пока не
# установлен в LFS системе
make headers || exit 1

# если пакет уже установлен, удалим его перед обновлением
if command -v removepkg &>/dev/null; then
    KERNEL_HEADERS_OLD_PGK="$(find /var/log/packages/ -type f -name "kernel-headers-*")"
    [ -n "${KERNEL_HEADERS_OLD_PGK}" ] &&
        /usr/sbin/removepkg --backup "${KERNEL_HEADERS_OLD_PGK}"
fi

# удалим не нужные файлы и скопируем заголовки в /usr/include/
find usr/include -type f ! -name '*.h' -delete
cp -rv usr/include "${LFS}/usr"

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
