#! /bin/bash

PART="/dev/sda10"

if [[ "$(whoami)" != "lfs" ]]; then
    echo "You need to login as lfs user"
    echo "  # su - lfs"
    exit 1
fi

if [[ "${LFS}" != "/mnt/lfs" ]]; then
    echo "Error: LFS=\"${LFS}\""
    echo "Environment variable 'LFS' must be equal '/mnt/lfs'"
    echo "Check your /home/lfs/.bashrc"
    exit 1
fi

if [[ "${LFS_TGT}" != "x86_64-lfs-linux-gnu" ]]; then
    echo "Error: LFS_TGT=\"${LFS_TGT}\""
    echo "Environment variable 'LFS_TGT' must be equal 'x86_64-lfs-linux-gnu'"
    echo "Check your /home/lfs/.bashrc"
    exit 1
fi

if [[ "${PATH}" != "${LFS}/tools/bin:/bin:/usr/bin" ]]; then
    echo "Error: PATH=\"${PATH}\""
    echo ""
    echo "Environment variable PATH must be equal '/tools/bin:/bin:/usr/bin'"
    echo "Check your /home/lfs/.bashrc"
    exit 1
fi

if ! mount | /bin/grep -q "${LFS}"; then
    echo "Mount point ${LFS} not mounted. You need to mount it:"
    echo "  # mount -v ${PART} ${LFS}"
    exit 1
fi
