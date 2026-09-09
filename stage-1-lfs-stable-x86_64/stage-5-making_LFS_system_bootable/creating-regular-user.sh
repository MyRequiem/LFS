#! /bin/bash

# Создание обычного пользователя LFS системы.

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

USERNAME="$1"

if [ -z "${USERNAME}" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

# -d    - Домашний каталог.
# -m    - Создать домашний каталог.
# -g    - Группа.
# -k    - Не копировать файлы/директории из /etc/skel (/dev/null).
# -s    - Оболочка.
useradd -d "/home/${USERNAME}" \
        -m                     \
        -g users               \
        -k /dev/null           \
        -s /bin/bash           \
        "${USERNAME}"

chown "${USERNAME}":users "/home/${USERNAME}"
chmod 711 "/home/${USERNAME}"
# Устанавливаем пароль для нового пользователя.
passwd "${USERNAME}"
