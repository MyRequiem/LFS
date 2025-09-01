#! /bin/bash

PRGNAME="etc-issue"
VERSION="12.4"

### /etc/issue (pre-login message)
# Файл /etc/issue содержит сообщения, которые выводятся до приглашения на вход
# в систему. Он может содержать различные последовательности @char и \char,
# которые читает утилита agetty

# в файле /etc/profile мы изменили $PATH и этот файл уже установлен в систему
# LFS, поэтому тест скрипта check_environment.sh в этой директории не будет
# пройден. Проверим окружение явно:
if [[ "$(id -u)" != "0" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

# мы в chroot окружении?
ID1="$(awk '$5=="/" {print $1}' < /proc/1/mountinfo)"
ID2="$(awk '$5=="/" {print $1}' < /proc/$$/mountinfo)"
if [[ "${ID1}" == "${ID2}" ]]; then
    echo "You must enter chroot environment."
    echo "Run 003_entering_chroot.sh script in this directory."
    exit 1
fi

# Очистка экрана - escape-последовательность '[H[J'
#     - Esc
# [H    - помещает курсор в верхний левый угол экрана
# [J    - стирает экран
# Такую escape-последовательность возвращает команда 'clear'
# clear > /etc/issue

# Другие последовательности:
# \b   baudrate of the current line, e.g. 38400
# \d   current date, e.g. Mon Mar 16 2020
# \s   system name, the name of the operating system, e.g. Linux
# \l   name of the current tty line, e.g. tty1
# \m   architecture identifier of the machine, e.g., x86_64
# \n   nodename of the machine, also known as the hostname, e.g. lfs
# \o   domainname of the machine
# \r   release number of the kernel, e.g. 5.9.3
# \t   current time, e.g. 23:23:26
# \u   number of current users logged in
# \U   string "N user" where N is the number of current users logged in
# \v   version of the OS, e.g., the build-date etc, e.g.
#       #2 SMP Fri Jun 24 13:38:27 CDT 2016

ISSUE="/etc/issue"
# Вид устанавливаемого приглашения:
# Linux 5.9.3 x86_64 (tty1)
# Fri Apr 10 [23:23:26]
printf " \\\s \\\r \\\m (\\\l)\\n \\\d [\\\t]\\n\\n" > "${ISSUE}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (pre-login message)
#
# /etc/issue is a text file which contains a message or system identification
# to be printed before the login prompt. It may contain various @char and
# \\char sequences, if supported by the getty-type program employed on the
# system
#
/etc
${ISSUE}
EOF
