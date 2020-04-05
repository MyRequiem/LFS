#! /bin/bash

# вход в среду chroot для сборки и установки основной системы LFS

if [[ "$(whoami)" != "root" ]]; then
    echo "Only superuser (root) can run this script"
    exit 1
fi

LFS="/mnt/lfs"
if ! mount | /bin/grep -q "${LFS}/proc"; then
    echo "You need to mount virtual file systems. Run script"
    echo "# ./002_mount_virtual_kernel_file_systems.sh --mount"
    exit 1
fi

RED="\[\033[1;31m\]"
MAGENTA="\[\033[1;35m\]"
RESETCOLOR="\[\033[0;0m\]"

# опция -i для команды env удалит все переменные кроме установленных явно
chroot "${LFS}" /tools/bin/env -i                                         \
    HOME="/root"                                                          \
    TERM="${TERM}"                                                        \
    PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin                         \
    PS1="\u ${MAGENTA}[LFS chroot]${RESETCOLOR}:${RED}\w\$${RESETCOLOR} " \
    /tools/bin/bash --login +h

# с этого момента больше нет необходимости использовать переменную ${LFS},
# потому что вся работа будет ограничена файловой системой LFS, т.е. корневым
# каталогом будет каталог ${LFS}

# Обратим внимание, что /tools/bin стоит последним в PATH. Это означает, что
# временный инструмент больше не будет использоваться после установки его
# окончательной версии. Такое поведение задается передачей аргумента +h команде
# bash. После этого оболочка не запоминает местоположения исполняемых двоичных
# файлов и при вызове каждый раз выполняет поиск в PATH

# В приглашение вместо имени пользователя bash скажет "I have no name!". Это
# нормально, потому что файл /etc/passwd еще не создан.
