#! /bin/bash

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

# для удобства дальнейшей работы создадим минимальный .bashrc для root
cat << EOF > "/root/.bashrc"
LS_OPTIONS="-F -b -T 0 --group-directories-first --color=auto"

alias v='/bin/ls \$LS_OPTIONS --format=long --time-style="+%d.%m.%y %H:%M:%S"'
alias vh='v --human-readable'

MAKEFLAGS="-j$(/usr/bin/nproc)"
export MAKEFLAGS
EOF

ln -svf .bashrc /root/.bash_profile

# создадим /etc/inputrc и настроим автодополнение путей в консоли по <TAB>
cat << EOF > "/etc/inputrc"
TAB: menu-complete
EOF

# современные ядра поддерживают список смонтированных файловых систем внутри
# себя и предоставляют его пользователю через файловую систему /proc, но
# некоторые программы читают этот список из файла /etc/mtab, поэтому создадим
# ссылку
ln -svf /proc/self/mounts /etc/mtab

# создадим базовый /etc/hosts, который нужен для конфигурации некоторых
# пакетов, например Perl
echo "127.0.0.1 localhost $(hostname)" > /etc/hosts

# чтобы пользователь root мог войти в систему и распознавать свое имя, в файлах
# /etc/passwd и /etc/group должны быть соответствующие записи
cat << EOF > "/etc/passwd"
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/dev/null:/bin/false
daemon:x:6:6:Daemon User:/dev/null:/bin/false
messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
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
wheel:x:97:
nogroup:x:99:
users:x:999:
EOF

# для некоторых дальнейших тестов нам понадобится обычный пользователь
# (позже мы его удалим)
echo "tester:x:1000:101::/home/tester:/bin/bash" \
    >> /etc/passwd
echo "tester:x:101:" \
    >> /etc/group
install -o tester -d /home/tester

# /var/log/
touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp
