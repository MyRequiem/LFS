#! /bin/bash

# вход в среду chroot

LFS="/mnt/lfs"

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

if ! mountpoint "${LFS}/proc" &>/dev/null; then
    echo "You need to mount virtual file systems. Run script:"
    echo "  # ./mount-virtual-kernel-file-systems.sh --mount"
    exit 1
fi

RED="\[\033[1;31m\]"
MAGENTA="\[\033[1;35m\]"
RESETCOLOR="\[\033[0;0m\]"

# опция -i для команды env удалит все переменные среды кроме установленных явно
chroot "${LFS}" /usr/bin/env -i                                           \
    HOME="/root"                                                          \
    TERM="${TERM}"                                                        \
    PATH=/usr/bin:/usr/sbin                                               \
    PS1="\u ${MAGENTA}[LFS chroot]${RESETCOLOR}:${RED}\w\$${RESETCOLOR} " \
    /bin/bash --login +h

# с этого момента больше нет необходимости использовать переменную ${LFS},
# потому что вся работа будет ограничена файловой системой LFS, т.е. ${LFS}
# будет являться корнем файловой системы

### NOTE:
# Во время первого входа в среду в приглашении вместо имени пользователя bash
# скажет "I have no name!". Это нормально, потому что файл /etc/passwd еще не
# создан.
