#! /bin/bash

# С этого момента входим в среду chroot с помощью этого скрита. Отличие в том,
# что оболочка bash уже скомпилирована и установлена в LFS систему, поэтому
# будем использовать именно ее.

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

LFS="/mnt/lfs"
if ! mount | /bin/grep -q "${LFS}/proc"; then
    echo "You need to mount virtual file systems. Run script"
    echo "  # ./002_mount_virtual_kernel_file_systems.sh --mount"
    exit 1
fi

RED="\[\033[1;31m\]"
MAGENTA="\[\033[1;35m\]"
RESETCOLOR="\[\033[0;0m\]"

# опция -i для команды env удалит все переменные кроме установленных явно
chroot "${LFS}" /tools/bin/env -i                                         \
    HOME="/root"                                                          \
    TERM="${TERM}"                                                        \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin                         \
    PS1="\u ${MAGENTA}[LFS chroot]${RESETCOLOR}:${RED}\w\$${RESETCOLOR} " \
    "/bin/bash" --login +h
