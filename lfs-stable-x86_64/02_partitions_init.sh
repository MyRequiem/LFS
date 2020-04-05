#! /bin/bash

# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html
# http://www.linuxfromscratch.org/lfs/view/stable/chapter04/creatingtoolsdir.html

LFS="/mnt/lfs"
PART="/dev/sda10"

# сначала нужно отмонтировать раздел на котором будем собирать LFS систему
# (если он примонтирован) и отформатировать его в ext4
echo "Attention!!!"
echo "Partition on which the system will be build: ${PART}"
echo -n "Do you want to format it to a ext4 file system? [yes/No]: "

read -r JUNK

if [[ "x${JUNK}" == "xyes" ]]; then
    umount "${PART}" &>/dev/null
    echo ""
    fdisk -l "${PART}"
    echo ""
    mkfs.ext4 -v "${PART}"
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

# создаем нужные директории:
# /mnt/lfs/sources
# /mnt/lfs/tools
mkdir -pv "${LFS}"/{sources,tools}
# разрешена запись всем пользователям, но удалять может только владелец
# каталога
chmod -v a+wt "${LFS}/sources"

# ссылка на хосте /tools -> /mnt/lfs/tools
ln -sfv "${LFS}/tools" /
