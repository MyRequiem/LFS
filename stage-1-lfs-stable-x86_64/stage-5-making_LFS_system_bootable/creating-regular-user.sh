#! /bin/bash

# создание обычного пользователя LFS системы

USERNAME="$1"

if [ -z "${USERNAME}" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

#    -d    - домашний каталог
#    -m    - создать домашний каталог
#    -g    - группа
#    -k    - не копировать файлы/директории из /etc/skel (/dev/null)
#    -s    - оболочка
useradd -d "/home/${USERNAME}" \
        -m                     \
        -g users               \
        -k /dev/null           \
        -s /bin/bash           \
        "${USERNAME}"

chown "${USERNAME}":users "/home/${USERNAME}"
chmod 711 "/home/${USERNAME}"
# устанавливаем пароль для нового пользователя
passwd "${USERNAME}"
