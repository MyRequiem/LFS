#! /bin/bash

# Создание основного дерева каталогов корневой файловой системы в соответствии
# с Filesystem Hierarchy Standard (FHS)
# https://refspecs.linuxfoundation.org/fhs.shtml

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

mkdir -pv /{boot,home,mnt,opt,srv}

# полный доступ к /root имеет только пользователь root, группа root только для
# чтения, остальные не имеют никакого доступа
install -dv -m 0750 /root
# любой пользователь может писать в /tmp и /var/tmp, но не может удалять из них
# файлы другого пользователя
install -dv -m 1777 /tmp /var/tmp

mkdir -pv /etc/{opt,sysconfig}
mkdir -pv /lib/firmware
mkdir -pv /media/{cdrom0,flash0,flash1}
mkdir -pv /usr/{,local/}share/man/man{1..8}
mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale}
mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
mkdir -pv /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv /var/lib/{color,misc,locate}
mkdir -pv /var/{cache,local,log,mail,opt,spool}

ln -svf cdrom0 /media/cdrom
ln -svf flash0 /media/flash

ln -sfv /run      /var/run
ln -sfv /run/lock /var/lock
