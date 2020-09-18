#! /bin/bash

# удаление отладочной информации (debugging symbols) из собранных бинарников

LFS="/mnt/lfs"

if [[ "$(id -u)" != "0" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

# мы = НЕ = должны быть в chroot окружении
ID1="$(awk '$5=="/" {print $1}' < /proc/1/mountinfo)"
ID2="$(awk '$5=="/" {print $1}' < /proc/$$/mountinfo)"
if [[ "${ID1}" != "${ID2}" ]]; then
    echo -n "This script needs to be run only from the host system, "
    echo "not from the chroot environment"
    exit 1
fi

# виртуальные файловые системы должны быть отмонтированы
if mount | /bin/grep -q "${LFS}/proc"; then
    echo "Virtual file systems must be unmounted. Run the script:"
    echo "./mount-virtual-kernel-file-systems.sh --umount"
    exit 1
fi

# NOTE:
#  Для библиотек нельзя использовать параметр --strip-unneeded, иначе они не
#  будут работать и их придется пересобирать заново
strip --strip-debug    "${LFS}/usr/lib"/*
strip --strip-unneeded "${LFS}/usr"/{,s}bin/*
strip --strip-unneeded "${LFS}/tools/bin"/*
