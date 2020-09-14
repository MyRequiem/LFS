#! /bin/bash

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

LFS="/mnt/lfs"
if ! mount | /bin/grep -q "${LFS}/proc"; then
    echo "You need to mount virtual file systems. Run script"
    echo -n "# ../02_build_basic_system/"
    echo "002_mount_virtual_kernel_file_systems.sh --mount"
    exit 1
fi

RED="\[\033[1;31m\]"
MAGENTA="\[\033[1;35m\]"
RESETCOLOR="\[\033[0;0m\]"

chroot "${LFS}" /usr/bin/env -i                                           \
    HOME="/root"                                                          \
    TERM="${TERM}"                                                        \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin                                    \
    PS1="\u ${MAGENTA}[LFS chroot]${RESETCOLOR}:${RED}\w\$${RESETCOLOR} " \
    /bin/bash --login
