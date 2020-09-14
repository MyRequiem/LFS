#! /bin/bash

# Виртуальные файловые системы ядра используются для связи с самим ядром. Эти
# файловые системы являются виртуальными, так как для них не используется
# дисковое пространство, а все их содержимое находится в памяти. Создадим
# виртуальные ФС в:
# /dev       - каталог /dev хоста
# /dev/pts   - devpts
# /proc      - proc
# /sys       - sysfs
# /run       - tmpfs
#
# В директорию /boot смонтируем /boot хоста для установки ядра linux

LFS="/mnt/lfs"
PART="/dev/sda10"

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

usage() {
    echo "Usage: $0 <--mount|--umount>"
}

UMOUNT=""
case "$1" in
    --mount)
        ;;
    --umount)
        UMOUNT="true";
        ;;
    *)
        usage
        exit 1
        ;;
esac

LFS_TMP_ON_HOST="/root/src/lfs-tmp"
if [ -n "${UMOUNT}" ]; then
    umount "${LFS_TMP_ON_HOST}"
    umount "${LFS}"/{dev{/pts,},proc,sys,run,boot} 2>/dev/null
    exit 0
fi

# смонтируем раздел LFS, если он не смонтирован
if ! mount | /bin/grep -q "${LFS}"; then
    mount -v "${PART}" "${LFS}"
fi

### Подготовка виртуальной файловой системы ядра
# ----------------------------------------------
# Когда ядро загружает систему, оно требует наличия нескольких узлов устройств,
# в частности консоли /dev/console и устройства /dev/null. Узлы устройства
# должны быть созданы на жестком диске, чтобы они были доступны до запуска
# udevd и, кроме того, когда ядро запускается с параметром init=/bin/bash

# если каталог ${LFS}/dev уже смонтирован, отмонтируем его
if mount | /bin/grep -q "${LFS}/dev"; then
    if mount | /bin/grep -q "${LFS}/dev/pts"; then
        umount -v "${LFS}/dev/pts"
    fi

    umount -v "${LFS}/dev"
fi

# создаем каталог ${LFS}/dev/ если он не существует (если скрипт запускается в
# первый раз)
! [ -d "${LFS}/dev" ] && mkdir -pv "${LFS}/dev"
# создаем символьные устройства /dev/console и /dev/null, если не существуют
! [ -e "${LFS}/dev/console" ] && \
    mknod -m 600 "${LFS}/dev/console" c 5 1
! [ -e "${LFS}/dev/null" ] && \
    mknod -m 666 "${LFS}/dev/null"    c 1 3

# рекомендуемый метод заполнения каталога /dev устройствами - это смонтировать
# виртуальную файловую систему (например, tmpfs) в каталоге /dev и позволить
# динамически создавать устройства в этой виртуальной файловой системе по мере
# их обнаружения или доступа к ним. Создание устройства обычно выполняется во
# время процесса загрузки Udev. Поскольку эта новая система еще не имеет Udev и
# еще не загружена, необходимо смонтировать и заполнить /dev вручную. Это
# достигается путем монтирования директории ${LFS}/dev с параметром --bind в
# каталог /dev хост-системы. --bind - это особый тип монтирования, который
# позволяет нам создать зеркало каталога или точку монтирования в каком-либо
# другом месте, т.е. зеркало файловой системы /dev хоста в каталоге ${LFS}/dev
mount -v --bind /dev "${LFS}/dev"

### Монтирование виртуальной файловой системы ядра
# ------------------------------------------------
# Устройства в /dev/pts - это устройства псевдотерминалов (pty). Они
# принадлежат группе tty с индентификатором 5 (gid=5). Используется именно
# идентификатор группы вместо имени, так как хост-система может использовать
# другой идентификатор для этой группы. Все узлы pty устройств, созданные
# devpts, имеют режим 0620 (mode=0620, -rw--w----, т.е. чтение и запись для
# пользователя и доступна запись для группы)
mount -vt devpts devpts "${LFS}/dev/pts" -o gid=5,mode=620

# ${LFS}/proc
if ! mount | /bin/grep -q "${LFS}/proc"; then
    ! [ -d "${LFS}/proc" ] && mkdir -pv "${LFS}/proc"
    mount -vt proc proc "${LFS}/proc"
fi

# ${LFS}/sys
if ! mount | /bin/grep -q "${LFS}/sys"; then
    ! [ -d "${LFS}/sys" ] && mkdir -pv "${LFS}/sys"
    mount -vt sysfs sysfs "${LFS}/sys"
fi

# ${LFS}/run
if ! mount | /bin/grep -q "${LFS}/run"; then
    ! [ -d "${LFS}/run" ] && mkdir -pv "${LFS}/run"
    mount -vt tmpfs tmpfs "${LFS}/run"
fi

# в некоторых хост-системах /dev/shm является символической ссылкой на
# /run/shm, поэтому в таком случае необходимо создать каталог /run/shm
if [ -h "${LFS}/dev/shm" ]; then
    mkdir -pv "${LFS}/$(readlink ${LFS}/dev/shm)"
fi

# если в хост-системе директория /boot находится на отдельно разделе, то ядро
# LFS системы должно быть установлено именно туда. Самый простой способ сделать
# это - смонтировать /boot хост системы в каталог /boot LFS-системы
if ! mount | /bin/grep -q "${LFS}/boot"; then
    ! [ -d "${LFS}/boot" ] && mkdir -pv "${LFS}/boot"
    mount -v --bind /boot "${LFS}/boot"
fi

# монтируем директорию на хосте на ${LFS}/tmp
if ! mount | /bin/grep -q "${LFS_TMP_ON_HOST}"; then
    ! [ -d "${LFS_TMP_ON_HOST}" ] && mkdir -p "${LFS_TMP_ON_HOST}"
    mount -v --bind "${LFS_TMP_ON_HOST}" "${LFS}/tmp/"
fi
