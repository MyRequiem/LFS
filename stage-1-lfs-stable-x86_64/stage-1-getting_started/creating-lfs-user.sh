#! /bin/bash

LFS="/mnt/lfs"

# создаем группу lfs если не существует
! grep -qE "^lfs:" /etc/group  && \
    groupadd lfs

# создаем пользователя lfs если не существует
if ! grep -qE "^lfs:" /etc/passwd ; then
    # -d    - домашний каталог
    # -m    - создать домашний каталог
    # -g    - группа
    # -k    - не копировать файлы/директории из /etc/skel (/dev/null)
    # -s    - оболочка
    useradd          \
        -d /home/lfs \
        -m           \
        -g lfs       \
        -k /dev/null \
        -s /bin/bash \
        lfs

    # устанавливаем пароль для пользователя lfs
    passwd lfs
fi

chown lfs:lfs /home/lfs
chmod 711 /home/lfs

# предоставим пользователю lfs полный доступ ко всем каталогам в LFS системе
chown -vR lfs:lfs "${LFS}"/*

BASH_PROFILE="/home/lfs/.bash_profile"
cat << EOF > "${BASH_PROFILE}"
# Begin ${BASH_PROFILE}

# с хоста никакие переменные среды брать не нужно, поэтому полностью обнуляем
# рабочее окружение командой env -i за исключением переменных HOME, TERM, и PS1
# Это гарантирует, что нежелательные и потенциально опасные переменные среды из
# хост-системы не попадут в среду сборки
exec env -i          \\
    HOME="\${HOME}"   \\
    TERM="\${TERM}"   \\
    PS1="\u@\h:\w\$ " \\
    /bin/bash

# теперь у пользователя lfs существует ~/.bash_profile, поэтому при его логине
# создается дочерний экземпляр оболочки, которая не будет читать /etc/profile,
# а будет читать только ~/.bash_profile и ~/.bashrc

# End ${BASH_PROFILE}
EOF

BASHRC="/home/lfs/.bashrc"
cat << EOF > "${BASHRC}"
# Begin ${BASHRC}

# отключаем хэш-функцию bash - запоминание полного пути исполняемых файлов,
# чтобы избежать повторного поиска в PATH. Таким образом, оболочка всегда
# сможет найти вновь скомпилированные инструменты в \${LFS}/tools (этот путь
# будет стоять первым в переменной окружения \$PATH), не запоминая предыдущую
# версию той же программы в другом месте
set +h
# установка пользовательской маски создания файлов на 022 гарантирует, что
# вновь созданные файлы и каталоги доступны для записи только их владельцу, а
# для всех остальных доступны только для чтения и исполнения, т.е. все файлы
# 644 и каталоги 755
umask 022

# директория сборки LFS
LFS="/mnt/lfs"
# контроль локализации некоторых программ и их сообщений, чтобы все их выводы в
# stdout были корректными
LC_ALL=C
# нестандартное, но совместимое описание машины для использования при сборке
# кросс-компилятора и компоновщика, а так же при кросс-компиляции нашего
# временного набора инструментов
LFS_TGT=x86_64-lfs-linux-gnu

PATH="\${LFS}/tools/bin:/bin:/usr/bin"
CONFIG_SITE="\${LFS}/usr/share/config.site"

# количество потоков сборки для 'make' установим равный количеству ядер
# процессора
MAKEFLAGS="-j\$(nproc)"

export LFS LC_ALL LFS_TGT PATH CONFIG_SITE MAKEFLAGS

alias vh='/bin/ls -F -b -T 0 --group-directories-first --color=auto --format=long --time-style="+%d.%m.%y %H:%M:%S" --human-readable'

# End ${BASHRC}
EOF

chown -v lfs:lfs /home/lfs/{.bash_profile,.bashrc}

echo -e "\nNow, you can login as a lfs user by entering the command\n# su - lfs"
