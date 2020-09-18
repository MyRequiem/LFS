#! /bin/bash

# http://www.linuxfromscratch.org/lfs/view/stable/chapter02/mounting.html
# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html

PART="/dev/sda10"
LFS="/mnt/lfs"

# Форматирование раздела в ext4
echo "Attention!!!"
echo "Partition on which the system will be build: ${PART}"
echo -n "Do you want to format it to a ext4 file system? [yes/No]: "

read -r JUNK

if [[ "x${JUNK}" == "xyes" ]]; then
    echo ""
    echo "*** Unmounting ${PART} partition:"
    umount "${PART}" 2>/dev/null
    fdisk -l "${PART}"
    echo ""
    echo "*** Creating ext4 file system on a partition ${PART}"
    mkfs.ext4 -v "${PART}"
    echo ""
else
    echo "Canceled ..."
    exit 0
fi

# создаем точку монтирования
mkdir -pv "${LFS}"

# монтируем раздел ${PART} в /mnt/lfs
# Если бы мы использовали несколько разделов для LFS, например отдельный раздел
# для /home, то нужно будет создать директорию ${LFS}/home и туда смонтировать
# другой раздел /dev/sdaXX, и т.д.
mount -vt ext4 "${PART}" "${LFS}"

# создаем нужные директории
mkdir -pv "${LFS}"/{bin,etc,lib,lib64,sbin,sources,tools,usr,var}

# запись в /sources разрешена всем, но удалять может только владелец каталога
chmod -v a+wt "${LFS}/sources"
