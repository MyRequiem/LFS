#! /bin/bash

PRGNAME="etc-issue"

### /etc/issue (pre-login message)
# Файл /etc/issue содержит сообщения, которые выводятся до приглашения на вход
# в систему. Он может содержать различные последовательности @char и \char,
# которые читает утилита agetty

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/logon.html

ROOT="/root"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

TMP_DIR="/tmp/build-${PRGNAME}/package-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

ISSUE="/etc/issue"
if [ -f "${ISSUE}" ]; then
    mv "${ISSUE}" "${ISSUE}.old"
fi

# Очистка экрана - escape-последовательность '[H[J'
#     - Esc
# [H    - помещает курсор в верхний левый угол экрана
# [J    - стирает экран
# Такую escape-последовательность возвращает команда 'clear'
# clear > "${ISSUE}"

# Другие последовательности:
# \b   baudrate of the current line, e.g. 38400
# \d   current date, e.g. Mon Mar 16 2020
# \s   system name, the name of the operating system, e.g. Linux
# \l   name of the current tty line, e.g. tty1
# \m   architecture identifier of the machine, e.g., x86_64
# \n   nodename of the machine, also known as the hostname, e.g. lfs
# \o   domainname of the machine
# \r   release number of the kernel, e.g., 5.5.15
# \t   current time
# \u   number of current users logged in
# \U   string "N user" where N is the number of current users logged in
# \v   version of the OS, e.g., the build-date etc, e.g.
#       #2 SMP Fri Jun 24 13:38:27 CDT 2016

# Linux 5.5.15 x86_64 (tty1)
# Fri Apr 10 [23:23:26]
printf " \\\s \\\r \\\m (\\\l)\\n \\\d [\\\t]\\n\\n" > "${ISSUE}"

cp "${ISSUE}" "${TMP_DIR}/etc/"
config_file_processing "${ISSUE}"

cat << EOF > "/var/log/packages/${PRGNAME}"
# Package: ${PRGNAME} (pre-login message)
#
# /etc/issue is a text file which contains a message or system identification
# to be printed before the login prompt. It may contain various @char and
# \\char sequences, if supported by the getty-type program employed on the
# system
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}"
