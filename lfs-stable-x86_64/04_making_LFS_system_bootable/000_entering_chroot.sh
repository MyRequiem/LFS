#! /bin/bash

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

LFS="/mnt/lfs"
if ! mount | /bin/grep -q "${LFS}/proc"; then
    echo "You need to mount virtual file systems."
    echo "Run script in ../002_build_basic_system/"
    echo "# ./002_mount_virtual_kernel_file_systems.sh --mount"
    exit 1
fi

# переменные окружения $PATH и $PS1 при входе в среду chroot теперь читаются из
# /etc/profile
chroot "${LFS}" /usr/bin/env -i \
    HOME="/root"                \
    TERM="${TERM}"              \
    /bin/bash --login
