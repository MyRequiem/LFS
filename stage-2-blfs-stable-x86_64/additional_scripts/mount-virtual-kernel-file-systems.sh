#! /bin/bash

# Для правильной работы chroot среды необходимо установить связь с работающим
# ядром с помощью виртуальных файловых систем. Эти файловые системы являются
# виртуальными, так как для них не используется дисковое пространство, а все их
# содержимое находится в памяти:
#    /dev       - каталог /dev хоста
#    /dev/pts   - devpts
#    /proc      - proc
#    /run       - tmpfs
#    /sys       - sysfs

PART="/dev/sda10"
LFS="/mnt/lfs"
# TMP_ON_HOST="/root/src/lfs-tmp"

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

usage() {
    echo "Usage: $0 <--mount|--umount>"
}

find_mnt() {
    findmnt | grep --color=auto "${LFS}"
}

case "$1" in
    --mount)
        ;;
    --umount)
        # umount "${TMP_ON_HOST}" &>/dev/null
        umount "${LFS}"/{dev{/pts,},proc,run,sys} &>/dev/null
        find_mnt
        exit 0
        ;;
    *)
        usage
        exit 1
        ;;
esac

# смонтируем LFS раздел
mount "${PART}" "${LFS}" &>/dev/null

! [ -d "${LFS}/dev" ] && mkdir -pv "${LFS}"/{dev/pts,proc,run,sys}

### Подготовка виртуальной файловой системы ядра
# ----------------------------------------------
# Когда ядро загружает систему, оно требует наличия нескольких узлов устройств,
# в частности консоли /dev/console и устройства /dev/null. Узлы устройства
# должны быть созданы на жестком диске, чтобы они были доступны до запуска
# udevd и, кроме того, когда ядро запускается с параметром init=/bin/bash

# если каталог ${LFS}/dev уже смонтирован, отмонтируем его
umount "${LFS}/dev/pts" &>/dev/null
umount "${LFS}/dev"     &>/dev/null

# создаем символьные устройства /dev/console и /dev/null, если не существуют
! [ -e "${LFS}/dev/console" ] && \
    mknod -m 600 "${LFS}/dev/console" c 5 1
! [ -e "${LFS}/dev/null" ] && \
    mknod -m 666 "${LFS}/dev/null"    c 1 3

# рекомендуемый метод заполнения каталога /dev устройствами - это смонтировать
# виртуальную файловую систему (например, tmpfs) в каталоге /dev и позволить
# динамически создавать устройства в этой виртуальной файловой системе по мере
# их обнаружения или доступа к ним. Создание устройства обычно выполняется во
# время процесса загрузки Udev. Поскольку наша новая система еще не имеет Udev
# и еще не загружена, необходимо смонтировать и заполнить /dev вручную. Это
# достигается путем монтирования директории ${LFS}/dev с параметром --bind в
# каталог /dev хост-системы. --bind - это особый тип монтирования, который
# позволяет нам создать зеркало каталога или точку монтирования в каком-либо
# другом месте, т.е. зеркало файловой системы /dev хоста в каталоге ${LFS}/dev
mount --bind /dev "${LFS}/dev" &>/dev/null

### Монтирование виртуальной файловой системы ядра
# ------------------------------------------------
# Устройства в /dev/pts - это устройства псевдотерминалов (pty). Монтируем
# /dev/pts хоста в /mnt/lfs/dev/pts
mount --bind /dev/pts "${LFS}/dev/pts" &>/dev/null

# proc, run, sys
if ! mount | /bin/grep -q "${LFS}/proc"; then
    mount -t proc  proc  "${LFS}/proc" &>/dev/null
fi

if ! mount | /bin/grep -q "${LFS}/run"; then
    mount -t tmpfs tmpfs "${LFS}/run"  &>/dev/null
fi

if ! mount | /bin/grep -q "${LFS}/sys"; then
    mount -t sysfs sysfs "${LFS}/sys"  &>/dev/null
fi

# в некоторых хост-системах /dev/shm является символической ссылкой на
# /run/shm, поэтому в таком случае необходимо создать каталог /run/shm
if [ -h "${LFS}/dev/shm" ]; then
    mkdir -pv "${LFS}/$(readlink ${LFS}/dev/shm)"
fi

# монтируем директорию на хосте на ${LFS}/tmp
# if ! mount | /bin/grep -q "${TMP_ON_HOST}"; then
#     ! [ -d "${TMP_ON_HOST}" ] && mkdir -p "${TMP_ON_HOST}"
#     mount -v --bind "${TMP_ON_HOST}" "${LFS}/tmp/"
# fi

find_mnt
