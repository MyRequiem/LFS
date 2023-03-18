#! /bin/bash

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

# для удобства дальнейшей работы создадим минимальный .bashrc для root
cat << EOF > "/root/.bashrc"
LS_OPTIONS="-F -b -T 0 --group-directories-first --color=auto"

alias v='/bin/ls \$LS_OPTIONS --format=long --time-style="+%d.%m.%y %H:%M:%S"'
alias vh='v --human-readable'

JOBS="-j$(/usr/bin/nproc)"
MAKEFLAGS="\${JOBS}"
NINJAJOBS="\${JOBS}"
export MAKEFLAGS NINJAJOBS
EOF

ln -svf .bashrc /root/.bash_profile

# создадим /etc/inputrc и настроим автодополнение путей в консоли по <TAB>
cat << EOF > "/etc/inputrc"
set bell-style none
set meta-flag On
set input-meta On
set convert-meta Off
set output-meta On
set echo-control-characters off

TAB: menu-complete

"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

"\C-p": history-search-backward
"\C-n": history-search-forward
"\C-h": backward-delete-char
EOF

# современные ядра поддерживают список смонтированных файловых систем внутри
# себя и предоставляют его пользователю через файловую систему /proc, но
# некоторые программы читают этот список из файла /etc/mtab, поэтому создадим
# ссылку
ln -svf /proc/self/mounts /etc/mtab

# создадим базовый /etc/hosts, который нужен для конфигурации некоторых
# пакетов, например Perl
cat << EOF > /etc/hosts
127.0.0.1 localhost $(hostname)
::1       localhost
EOF

# чтобы пользователь root мог войти в систему и распознавать свое имя, в файлах
# /etc/passwd и /etc/group должны быть соответствующие записи
cat << EOF > "/etc/passwd"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/usr/bin/false
daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF

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
EOF

# для некоторых дальнейших тестов нам понадобится обычный пользователь (позже
# мы его удалим)
echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
echo "tester:x:101:" >> /etc/group
install -o tester -d /home/tester

# /var/log/
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp
