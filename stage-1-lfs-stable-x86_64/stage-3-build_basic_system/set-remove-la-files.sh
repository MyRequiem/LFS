#! /bin/bash

# В LFS мы установили пакет libtool, который используется многими пакетами для
# сборки на различных платформах Unix. Истоки этого инструмента довольно
# устарели. Он был предназначен для управления библиотеками в системах с менее
# продвинутыми возможностями, чем в современной системе Linux. В системе Linux
# специфичные для libtool файлы (файлы с расширением *.la) обычно не нужны.
# Библиотеки определяются в процессе сборки на этапе линковки. Поскольку Linux
# использует исполняемый и связываемый формат (ELF) для исполняемых файлов и
# библиотек, информация, необходимая для выполнения задачи, встроена в
# исполняемые файлы. Во время выполнения загрузчик программы может запрашивать
# соответствующую информацию из файлов и правильно загружать и выполнять
# программу. Проблема в том, что libtool обычно создает один или несколько
# текстовых файлов для библиотек пакетов, называемых libtool-архивами. Эти
# небольшие файлы содержат информацию, аналогичную той, которая встроена в
# библиотеки. При создании пакета, который использует libtool, процесс
# автоматически ищет эти файлы. Если новая версия пакета больше не использует
# файл .la, процесс сборки может прерваться. Решение состоит в том, чтобы
# удалить файлы .la. Однако есть подвох. Некоторые пакеты, такие как
# ImageMagick-7.0.8-60, используют функцию libtool, lt_dlopen, для загрузки
# библиотек по мере необходимости во время выполнения и разрешения их
# зависимостей. В этом случае файлы .la должны остаться.
#
# libtool-архивы находятся в каталогах /usr/lib и /usr/libexec. Данный
# сценарий, создает скрипт /usr/sbin/remove-la-files.sh, который при запуске
# удаляет все ненужные файлы .la и сохраняет их в каталоге
# /var/log/removed_la_files. Он также ищет во всех файлах pkg-config (файлы с
# расширением *.pc) встроенные ссылки на файлы *.la и исправляет их на обычные
# ссылки на библиотеки, необходимые при сборке приложения или библиотеки.
#
# Скрипт можно запускать по мере необходимости для очистки каталогов, которые
# могут вызывать проблемы.

ROOT="/"
source "${ROOT}/check_environment.sh" || exit 1

SCRIPT="/usr/sbin/remove-la-files.sh"
cat > "${SCRIPT}" << "EOF"
#!/bin/bash

# /usr/sbin/remove-la-files.sh
# Written for Beyond Linux From Scratch
# by Bruce Dubbs <bdubbs@linuxfromscratch.org>
# Edited by MyRequiem <mrvladislavovich@gmail.com>

# make sure we are running with root privileges
if test "${EUID}" -ne 0; then
    echo "Error: $(basename ${0}) must be run as the root user! Exiting..."
    exit 1
fi

# make sure PKG_CONFIG_PATH is set if discarded by sudo
[ -r /etc/profile ] && source /etc/profile

OLD_LA_DIR=/var/log/removed_la_files

mkdir -p $OLD_LA_DIR

# only search directories in /opt, but not symlinks to directories
OPTDIRS=$(find /opt -mindepth 1 -maxdepth 1 -type d)

# move any found .la files to a directory out of the way
find /usr/lib /usr/libexec $OPTDIRS -name "*.la" ! -name "libosp.la" \
    ! -path "/usr/lib/ImageMagick*" -exec mv -fv {} $OLD_LA_DIR \;

###############

# fix any .pc files that may have .la references

STD_PC_PATH='/usr/lib/pkgconfig
             /usr/share/pkgconfig
             /usr/local/lib/pkgconfig
             /usr/local/share/pkgconfig'

# for each directory that can have .pc files
for d in $(echo $PKG_CONFIG_PATH | tr : ' ') $STD_PC_PATH; do
  # for each pc file
  for pc in $d/*.pc ; do
    if [ $pc == "$d/*.pc" ]; then continue; fi

    # check each word in a line with a .la reference
    for word in $(grep '\.la' $pc); do
      if $(echo $word | grep -q '.la$' ); then
        mkdir -p $d/la-backup
        cp -fv  $pc $d/la-backup

        basename=$(basename $word )
        libref=$(echo $basename|sed -e 's/^lib/-l/' -e 's/\.la$//')

        # fix the .pc file
        sed -i "s:$word:$libref:" $pc
      fi
    done
  done
done
EOF

chmod 744 "${SCRIPT}"
