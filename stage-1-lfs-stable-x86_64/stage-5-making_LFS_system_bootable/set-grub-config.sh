#! /bin/bash

# Установка в /boot конфигов для GRUB и установка GRUB в загрузочную запись
# (MBR) жесткого диска.

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

###
# Данные GRUB находятся в /boot/grub. Главный файл конфигурации:
#    /boot/grub/grub.cfg
###

HD="/dev/sda"
GRUB_DIR="/boot/grub"
GRUB_CONFIG="${GRUB_DIR}/grub.cfg"
mkdir -pv "${GRUB_DIR}"

# В целях защиты главного конфига от его перезаписи, например при обновлении
# пакета Grub, для /boot/grub/grub.cfg нужно запретить редактирование на уровне
# файловой системы путем присвоения ему атрибута 'immutable' и оставить в нем
# только одну строку со ссылкой на другой файл, например menu.cfg и в
# дальнейшем вместо grub.cfg править только menu.cfg Нужно обязательно
# указывать переменную $prefix. Если указать полный путь как
# /boot/grub/menu.cfg, то система не загрузится
echo "# Creating ${GRUB_DIR}/grub.cfg ..."
echo ". \$prefix/menu.cfg" > ${GRUB_CONFIG}
echo "# cat ${GRUB_CONFIG}"
cat "${GRUB_CONFIG}"
echo ""

# присваиваем атрибут 'immutable' для /boot/grub/grub.cfg
echo "# Current attributes for ${GRUB_CONFIG}"
lsattr ${GRUB_CONFIG}
echo "# Assign an attribute 'immutable' to ${GRUB_CONFIG}"
chattr +i "${GRUB_CONFIG}"
lsattr ${GRUB_CONFIG}
echo ""
# если потребуется, снять блокировку можно командой:
#    # chattr -i /boot/grub/grub.cfg

###
# Конфигурация загрузочного меню /boot/grub/menu.cfg
###
#
# GRUB использует собственную структуру имен для дисков и разделов в виде
# (hdN, M), где
#    N - номер жесткого диска (отсчет с нуля)
#    M - номер раздела
#    Например:
#         /dev/sda1 - (hd0,1)
#         /dev/sdb3 - (hd1,3)
#
# Текущая конфигурация:
# ---------------------
# |-sda1  /boot [LFS]
#           |
#           vmlinuz -> vmlinuz-generic-6.1.15
# |-sda5  /     [корень LFS]
# |-sda8  /     [корень Slackware]
#         |
#         boot
#           |
#           vmlinuz-4.4.276.generic

# пункт меню по умолчанию
#    set default=0
# задержка перед автозапуском при неактивности пользователя (сек)
#    set timeout=7
# если директория /boot является отдельным разделом на жестком диске, то нужно
# его указать, а в строке: linux <kernel_path> указывать /<kernel>
#    set root=(hd0,1)
# корневой раздел файловой системы linux, который будет монтироваться в режиме
# read-only
#    root=/dev/sdaX
# параметры передаваемые ядру при его загрузке
#    net.ifnames=0 vt.default_utf8=1
GRUB_MENU="${GRUB_DIR}/menu.cfg"
echo "Creating ${GRUB_MENU} ..."
echo ""
cat << EOF > "${GRUB_MENU}"
# Begin ${GRUB_MENU}

set default=0
set timeout=7

# LFS
menuentry "GNU/Linux, LFS-11.3 Linux-6.1.15" {
    set root=(hd0,1)
    linux /vmlinuz root=${HD}5 ro net.ifnames=0 vt.default_utf8=1
}

# Slackware
menuentry "GNU/Linux, Slackware-15.0 Linux-4.4.276" {
    set root=(hd0,8)
    linux /boot/vmlinuz-4.4.276.generic root=${HD}8 ro net.ifnames=0 vt.default_utf8=1
}

# End ${GRUB_MENU}
EOF

# Установим файлы GRUB и перезапишем загрузочную запись (MBR), после чего можно
# перезапускать систему
echo "Installing GRUB to MBR:"
grub-install "${HD}"
# если при выполнении команды происходит ошибка, то добавим парамтр --recheck
# grub-install --recheck ${HD}
