#! /bin/bash

# sda
#    |-sda1      100M    /boot    *
#    |-sda2      1G      [SWAP]
#    |-sda3      1K      [Extended]
#    |  -sda5    70G     /
#    |  -sda6    150G    /home
#    |  -sda7    30G     /tmp
#    |  -sda8    20G     [HOST]
#    |  -sda9    27G     [empty]

# корневой раздел LFS
PART="/dev/sda5"
# разделы /boot, /home, /tmp
BOOT="/dev/sda1"
HOME="/dev/sda6"
TMP="/dev/sda7"

# точка монтирования
LFS="/mnt/lfs"

# Форматирование корневого раздела LFS в ext4
echo "Attention!!!"
echo -en "Partition on which the system will be build:\n>>>    "
fdisk -l "${PART}" | head -n 1
echo -n "Do you want to format it to a ext4 file system? [yes/No]: "

read -r JUNK

if [[ "x${JUNK}" == "xyes" ]]; then
    echo ""
    echo "*** Creating ext4 file system on a partition ${PART}"
    mkfs.ext4 -v "${PART}"
else
    echo "Canceled ..."
    exit 0
fi

# создаем точку монтирования
mkdir -p "${LFS}"

# монтируем раздел /dev/sda5 в /mnt/lfs
mount -vt ext4 "${PART}" "${LFS}"
echo ""

# создаем нужные директории и монтируем остальные разделы
mkdir -pv "${LFS}"/{boot,etc,home,lib64,sources,tmp,tools,usr,var}
mkdir -pv "${LFS}"/usr/{bin,lib,share,sbin}
echo ""
# ссылки в корневой файловой системе:
#    /bin  -> usr/bin
#    /lib  -> usr/lib
#    /sbin -> usr/sbin
for ROOT_DIR in bin lib sbin; do
    ln -svf "usr/${ROOT_DIR}" "${LFS}/${ROOT_DIR}"
done
echo ""

# если мы использyем несколько разделов для LFS, например отдельный раздел для
# /home, то нужно будет его отформатировать создавая файловую систему ext4 и
# смонтировать /dev/sdaXX в /home
mkfs.ext4 -v "${BOOT}"
mount -vt ext4 "${BOOT}" "${LFS}/boot"
echo ""

mkfs.ext4 -v "${HOME}"
mount -vt ext4 "${HOME}" "${LFS}/home"
echo ""

mkfs.ext4 -v "${TMP}"
mount -vt ext4 "${TMP}"  "${LFS}/tmp"
echo ""

# запись в /sources разрешена всем, но удалять может только владелец каталога
chmod a+wt "${LFS}/sources"

# выведем смонтированные разделы в консоль
findmnt
