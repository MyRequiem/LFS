#! /bin/bash

PRGNAME="etc-inputrc"
LFS_VERSION="11.3"

### /etc/inputrc (configures keyboard input for programs using readline)
# /etc/inputrc - файл конфигурации библиотеки Readline, который предоставляет
# возможности редактирования во время ввода в терминал. Переопределить
# конфигурацию /etc/inputrc можно в файле ~/.inputrc для каждого пользователя.

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

ROOT="/"
TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

INPUTRC="/etc/inputrc"
cat << EOF > "${TMP_DIR}${INPUTRC}"
# Begin ${INPUTRC}

# This file configures keyboard input for programs using readline.
# See 'man 3 readline' for more examples.

# configure the system bell (none, visible, and audible)
set bell-style none

# enable 8 bit input
set meta-flag On
set input-meta On

# turns off 8th bit stripping
set convert-meta Off

# keep the 8th bit for display
set output-meta On

TAB: menu-complete

set echo-control-characters off

# disable highlighted pasted text in the terminal
set enable-bracketed-paste off

### for linux console
"\\e[1~": beginning-of-line
"\\e[4~": end-of-line
"\\e[5~": beginning-of-history
"\\e[6~": end-of-history
"\\e[3~": delete-char
"\\e[2~": quoted-insert

### for xterm
"\\C-p": history-search-backward
"\\C-n": history-search-forward
"\\C-h": backward-delete-char

# End ${INPUTRC}
EOF

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${LFS_VERSION}"
# Package: ${PRGNAME} (configures keyboard input for programs using readline)
#
# /etc/inputrc
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${LFS_VERSION}"
