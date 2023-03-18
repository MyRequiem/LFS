#! /bin/bash

PKGNAME="main-directory-tree"

# Создание основного дерева каталогов корневой файловой системы, основанного на
# Filesystem Hierarchy Standard (FHS)
# https://refspecs.linuxfoundation.org/fhs.shtml

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

mkdir -pv           /boot
mkdir -pv           /dev/pts
mkdir -pv           /etc/{opt,profile.d,skel,sysconfig}
mkdir -pv           /home
mkdir -pv           /usr/lib/firmware
mkdir -pv           /lib64
mkdir -pv           /media/{flash{0,1},cdrom0}
mkdir -pv           /mnt/{hdd{0,1},iso,repo,src}
mkdir -pv           /opt
mkdir -pv           /proc
install -dv -m 0750 /root
mkdir -pv           /run
mkdir -pv           /srv
mkdir -pv           /sys
install -dv -m 1777 /tmp
mkdir -pv           /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv           /usr/{,local/}share/{color,dict,doc,info,locale}
mkdir -pv           /usr/{,local/}share/{man,misc,terminfo,zoneinfo}
mkdir -pv           /usr/{,local/}share/man/man{1..8}
mkdir -pv           /usr/libexec
mkdir -pv           /usr/lib/pkgconfig
install -dv -m 1777 /var/{cache,mail,spool,tmp,lib/{color,misc,locate}}
mkdir -pv           /var/log/{packages,removed_packages,setup/tmp/preserved}

# исторически Linux поддерживает список смонтированных файловых систем в файле
# /etc/mtab. Современные ядра поддерживают этот список внутренне и
# предоставляют его пользователю через файловую систему /proc. Чтобы
# удовлетворить зависимости утилит, которые ожидают наличия /etc/mtab, создадим
# символическую ссылку
rm -f   /etc/mtab
ln -svf /proc/self/mounts /etc/mtab

# чтобы пользователь root мог войти в систему и чтобы имя 'root' было
# распознано, в файлах /etc/group и /etc/passwd должны быть соответствующие
# записи
# фактический пароль для пользователя root (используемый здесь "x" - просто
# заполнитель) будет установлен позже
cat << EOF > "/etc/group"
root:x:0:
bin:x:1:daemon
sys:x:2:
kmem:x:3:
tape:x:4:
tty:x:5:
daemon:x:6:
floppy:x:7:
disk:x:8:
lp:x:9:
dialout:x:10:
audio:x:11:
video:x:12:
utmp:x:13:
usb:x:14:
cdrom:x:15:
adm:x:16:
messagebus:x:18:
input:x:24:
mail:x:34:
kvm:x:61:
uuidd:x:80:
wheel:x:97:
users:x:999:
nogroup:x:99:
tester:x:101:
EOF

cat << EOF > "/etc/passwd"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
tester:x:101:101::/home/tester:/bin/bash
EOF

(
    cd /media || exit 1
    rm -f cdrom flash
    ln -svf cdrom0 cdrom
    ln -svf flash0 flash
)

(
    cd /usr || exit 1
    rm -f doc
    ln -svf share/doc doc
)

(
    cd /var || exit 1
    rm -f run lock
    ln -svf /run run
    ln -svf /run/lock lock
)

# Программы login, agetty, init и другие используют ряд файлов журналов для
# записи информации, например, кто вошел в систему и когда. Однако эти
# программы не будут писать логи, если сами файлы логов не существуют.
# Инициализируем файлы журналов и предоставим им соответствующие разрешения
# /var/log/wtmp    - все входы и выходы из системы
# /var/log/lastlog - последний вход каждого пользователя
# /var/log/faillog - неудачные попытки входа в систему
# /var/log/btmp    - неудачные попытки входа в систему
touch /var/log/{wtmp,btmp,lastlog,faillog}
chmod -v 600  /var/log/btmp
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog

cat << EOF > "/var/log/packages/${PKGNAME}"
# Package: ${PKGNAME} (Main directories and system files)
#
# The main tree of the root file system. This package cannot be removed.
#
/boot
/dev
/dev/pts
/etc
/etc/group
/etc/mtab
/etc/opt
/etc/passwd
/etc/profile.d
/etc/skel
/etc/sysconfig
/home
/lib64
/media
/media/cdrom
/media/cdrom0
/media/flash
/media/flash0
/media/flash1
/mnt
/mnt/hdd0
/mnt/hdd1
/mnt/iso
/mnt/repo
/mnt/src
/opt
/proc
/root
/run
/srv
/sys
/tmp
/usr
/usr/bin
/usr/doc
/usr/include
/usr/lib
/usr/lib/firmware
/usr/lib/pkgconfig
/usr/libexec
/usr/local
/usr/local/bin
/usr/local/include
/usr/local/lib
/usr/local/sbin
/usr/local/share
/usr/local/share/color
/usr/local/share/dict
/usr/local/share/doc
/usr/local/share/info
/usr/local/share/locale
/usr/local/share/man
/usr/local/share/man/man1
/usr/local/share/man/man2
/usr/local/share/man/man3
/usr/local/share/man/man4
/usr/local/share/man/man5
/usr/local/share/man/man6
/usr/local/share/man/man7
/usr/local/share/man/man8
/usr/local/share/misc
/usr/local/share/terminfo
/usr/local/share/zoneinfo
/usr/local/src
/usr/sbin
/usr/share
/usr/share/color
/usr/share/dict
/usr/share/doc
/usr/share/info
/usr/share/locale
/usr/share/man
/usr/share/man/man1
/usr/share/man/man2
/usr/share/man/man3
/usr/share/man/man4
/usr/share/man/man5
/usr/share/man/man6
/usr/share/man/man7
/usr/share/man/man8
/usr/share/misc
/usr/share/terminfo
/usr/share/zoneinfo
/usr/src
/var
/var/cache
/var/lib
/var/lib/color
/var/lib/locate
/var/lib/misc
/var/lock
/var/log
/var/log/btmp
/var/log/faillog
/var/log/lastlog
/var/log/packages
/var/log/removed_packages
/var/log/setup
/var/log/setup/tmp
/var/log/setup/tmp/preserved
/var/log/wtmp
/var/mail
/var/run
/var/spool
/var/tmp
EOF
