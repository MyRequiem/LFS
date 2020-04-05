#! /bin/bash

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter03/introduction.html
# http://www.linuxfromscratch.org/lfs/view/9.0/chapter04/creatingtoolsdir.html

LFS="/mnt/lfs"
PART="/dev/sda10"

# сначала нужно отформатировать раздел, на котором будем собирать систему LFS.
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
fi

# создаем точку монтирования
! [ -d "${LFS}" ] && mkdir -pv "${LFS}"

# монтируем раздел ${PART} в /mnt/lfs
# Если бы мы использовали несколько разделов для LFS, например отдельный раздел
# для /home, то нужно будет создать директорию ${LFS}/home и туда смонтировать
# другой раздел /dev/sdaXX, и т.д.
if ! mount | /bin/grep -q "${PART}"; then
    mount -v -t ext4 "${PART}" "${LFS}"
fi

# создаем нужные директории:
# /mnt/lfs/sources
# /mnt/lfs/tools
# и ссылку на хосте /tools -> /mnt/lfs/tools
if ! [ -d "${LFS}/sources" ]; then
    mkdir -pv "${LFS}/sources"
    # разрешена запись всем пользователям, но удалять может только владелец
    # каталога
    chmod -v a+wt "${LFS}/sources"
fi

if ! [ -d "${LFS}/tools" ]; then
    mkdir -pv "${LFS}/tools"
fi

if ! [ -L /tools ]; then
    ln -sv "${LFS}/tools" /
fi
