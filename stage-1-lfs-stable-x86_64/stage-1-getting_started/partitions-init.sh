#! /bin/bash

# sda
# |-sda1  100M   /boot
# |-sda2    1G   [SWAP]
# |-sda3    1K   [Extended]
# |  -sda5  100G /
# |  -sda6  150G /home
# |  -sda7   25G /tmp
# |  -sda8   22G [HOST Slackware 15.0]

# корневой раздел LFS
PART="/dev/sda5"

BOOT="/dev/sda1"
HOME="/dev/sda6"
TMP="/dev/sda7"

# точка монтирования
LFS="/mnt/lfs"

# Форматирование корневого раздела LFS в ext4
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

# создаем нужные директории и монтируем остальные разделы
mkdir -pv "${LFS}"/{boot,etc,home,lib64,sources,tmp,tools,usr,var}
mkdir -pv "${LFS}"/usr/{bin,lib,share,sbin}

# ссылки в корневой файловой системе:
#    /bin  -> usr/bin
#    /lib  -> usr/lib
#    /sbin -> usr/sbin
for ROOT_DIR in bin lib sbin; do
    ln -svf "usr/${ROOT_DIR}" "${LFS}/${ROOT_DIR}"
done

mount -vt ext4 "${BOOT}" "${LFS}/boot"
mount -vt ext4 "${HOME}" "${LFS}/home"
mount -vt ext4 "${TMP}"  "${LFS}/tmp"

# запись в /sources разрешена всем, но удалять может только владелец каталога
chmod -v a+wt "${LFS}/sources"
