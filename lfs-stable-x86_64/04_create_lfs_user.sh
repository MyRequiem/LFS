#! /bin/bash

LFS="/mnt/lfs"

# создаем группу lfs если не существует
GROUP_EXISTS=$(grep lfs < /etc/group)
if [ -z "${GROUP_EXISTS}" ]; then
    groupadd lfs
fi

# создаем пользователя lfs если не существует
USER_EXISTS=$(grep lfs < /etc/passwd)
if [ -z "${USER_EXISTS}" ]; then
    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
    # -s    - оболочка по умолчанию
    # -g    - добавления пользователя в группу
    # -m    - создает домашний каталог пользователя
    # -k    - не копировать файлы/директории из /etc/skel, т.к. указываем
    #           /dev/null
    # lfs   - имя пользователя

    # устанавливаем пароль для пользователя
    passwd lfs
fi

# предоставим пользователю lfs полный доступ к каталогам ${LFS}/tools и
# ${LFS}/sources, сделав его владельцем этих каталогов
chown lfs:root "${LFS}/tools"
chown lfs:root "${LFS}/sources"

### ~/.bash_profile
cat > /home/lfs/.bash_profile << "EOF"
# с хоста никакие переменные среды брать не нужно, поэтому полностью обнуляем
# рабочее окружение командой env -i за исключением переменных HOME, TERM, и PS1
# Это гарантирует, что нежелательные и потенциально опасные переменные среды из
# хост-системы не попадут в среду сборки
exec env -i        \
    HOME="${HOME}" \
    TERM="${TERM}" \
    PS1="\u:\w\$ " \
    /bin/bash

# Т.к. у пользователя lfs существует ~/.bash_profile, то при логине как
# пользователь lfs создается дочерний экземпляр оболочки, которая не будет
# читать /etc/profile, а будет читать ~/.bash_profile и ~/.bashrc
EOF

### ~/.bashrc
cat > /home/lfs/.bashrc << "EOF"
# отключаем хэш-функцию bash - запоминание полного пути исполняемых файлов,
# чтобы избежать повторного поиска в PATH. Таким образом, оболочка всегда
# сможет найти вновь скомпилированные инструменты в ${LFS}/tools (этот путь
# будет стоять первым в переменной окружения $PATH), не запоминая предыдущую
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
LFS_TGT=$(uname -m)-lfs-linux-gnu

PATH=/tools/bin:/bin:/usr/bin

# количество потоков сборки для 'make' (количество процессоров + 1)
MAKEFLAGS="-j$(($(nproc) + 1))"

export LFS LC_ALL LFS_TGT PATH MAKEFLAGS

alias vh='/bin/ls -F -b -T 0 --group-directories-first --color=auto --format=long --time-style="+%d.%m.%y %H:%M:%S" --human-readable'
EOF

### ~/.vimrc
cat > /home/lfs/.vimrc << "EOF"
let skip_defaults_vim=1
set nocompatible
syntax on
set background=dark
set number
set backspace=indent,eol,start
set nobackup
set noswapfile
set noundofile
set smarttab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set shiftround
set expandtab
EOF

chown -v lfs:lfs /home/lfs/{.bash_profile,.bashrc,.vimrc}

echo -e "\nNow, you can login as a lfs user by entering the command\n# su - lfs"
