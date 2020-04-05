#! /tools/bin/bash

# Создаем основную структуру в файловой системе LFS

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

mkdir -pv           /bin
mkdir -pv           /etc/profile.d
mkdir -pv           /etc/skel
mkdir -pv           /etc/sysconfig
mkdir -pv           /home
mkdir -pv           /lib/firmware
mkdir -pv           /lib64
mkdir -pv           /media/{flash{1,2},cdrom}
mkdir -pv           /mnt/{hdd{1,2},iso,repo,src}
mkdir -pv           /opt
install -dv -m 0750 /root
mkdir -pv           /sbin
mkdir -pv           /srv
install -dv -m 1777 /tmp
mkdir -pv           /usr/{,local/}{bin,include,lib,sbin,src}
mkdir -pv           /usr/{,local/}share/{color,dict,doc,info,locale}
mkdir -pv           /usr/{,local/}share/{man,misc,terminfo,zoneinfo}
mkdir -pv           /usr/{,local/}share/man/man{1..8}
mkdir -pv           /usr/libexec
mkdir -pv           /usr/lib/pkgconfig
install -dv -m 1777 /var/{cache,mail,spool,tmp,lib/{color,misc,locate}}
mkdir -pv           /var/log/{packages,removed_packages,setup/tmp/preserved}

(
    cd /var || exit 1
    rm -f run lock
    ln -sf /run run
    ln -sf /run/lock lock
)

# некоторые программы используют жесткие пути к другим программам, которые еще
# не установлены в нашей системе. Чтобы удовлетворить зависимости этих
# программ, создадим ряд символических ссылок, которые будут заменены реальными
# файлами в ходе сборки LFS
ln -sv /tools/bin/{bash,cat,chmod,dd,echo,ln,mkdir,pwd,rm,stty,touch} /bin
ln -sv bash /bin/sh
ln -sv /tools/bin/{env,install,perl,printf} /usr/bin
ln -sv /tools/lib/libgcc_s.so{,.1}          /usr/lib
ln -sv /tools/lib/libstdc++.{a,so{,.6}}     /usr/lib

# исторически Linux поддерживает список смонтированных файловых систем в файле
# /etc/mtab. Современные ядра поддерживают этот список внутренне и
# предоставляют его пользователю через файловую систему /proc. Чтобы
# удовлетворить зависимости утилит, которые ожидают наличия /etc/mtab, создадим
# символическую ссылку
ln -sv /proc/self/mounts /etc/mtab

# чтобы пользователь root мог войти в систему и чтобы имя 'root' было
# распознано, в файлах /etc/passwd и /etc/group должны быть соответствующие
# записи
cat > /etc/passwd << "EOF"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF

# фактический пароль для пользователя root (используемый здесь "x" - просто
# заполнитель) будет установлен позже
cat > /etc/group << "EOF"
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
wheel:x:97:
nogroup:x:99:
users:x:100:
EOF

# Созданные групп не являются частью какого-либо стандарта - они являются
# группами, определяемыми частично требованиями конфигурации Udev и частично
# общим соглашением, используемым рядом существующих дистрибутивов Linux. Кроме
# того, некоторые тестовые наборы зависят от конкретных пользователей или
# групп. Стандартная база Linux рекомендует присутствие кроме группы с ID 0
# (root) группы с ID 1 (bin). Все другие имена групп и GID могут быть свободно
# выбраны системным администратором, поскольку хорошо написанные программы не
# зависят от номеров GID, а скорее используют имя группы.

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

cat > /var/log/packages/main-directory-tree-9.0 << "EOF"
# Package: main-directory-tree (Main directories and system files)
#
# The main tree of the root file system. This package cannot be removed.
#
/bin
/bin/sh
/boot
/dev
/etc
/etc/group
/etc/mtab
/etc/passwd
/etc/profile.d
/etc/skel
/etc/sysconfig
/home
/lib
/lib/firmware
/lib64
/media
/media/cdrom
/media/flash1
/media/flash2
/mnt
/mnt/hdd1
/mnt/hdd2
/mnt/iso
/mnt/repo
/mnt/src
/opt
/proc
/root
/run
/sbin
/srv
/sys
/tmp
/usr
/usr/bin
/usr/include
/usr/lib
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
