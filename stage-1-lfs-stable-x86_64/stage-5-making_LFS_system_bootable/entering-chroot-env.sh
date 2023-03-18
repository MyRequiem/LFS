#! /bin/bash

# вход в среду chroot

LFS="/mnt/lfs"

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

if ! mountpoint "${LFS}/proc" &>/dev/null; then
    echo "You need to mount virtual file systems. Run script:"
    echo "  # ./mount-virtual-kernel-file-systems.sh --mount"
    exit 1
fi

# $PATH и $PS1 при входе в среду chroot теперь читаются из /etc/profile
chroot "${LFS}" /usr/bin/env -i \
    HOME="/root"                \
    TERM="${TERM}"              \
    /bin/bash --login
