#! /bin/bash

PRGNAME="ncurses"

### Ncurses
# Библиотека, написанная на языках Си и Ада, предназначенная для управления
# вводом-выводом на терминал. Так же библиотека позволяет задавать экранные
# координаты и цвет выводимых символов. Предоставляет программисту уровень
# абстракции, позволяющий не беспокоиться об аппаратных различиях терминалов и
# писать переносимый код

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# во время конфигурации gawk должен быть обнаружен первым, вместо mawk
sed -i s/mawk// configure

# соберем утилиту 'tic'
mkdir build
pushd build       || exit 1
../configure      || exit 1
make -C include   || exit 1
make -C progs tic || exit 1
popd              || exit 1

# не сжимать man-страницы в .gz
#    --with-manpage-format=normal
# Ncurses не должен создавать поддержку для компилятора Ada, который может
# присутствовать на хосте, но не будет доступен после входа в среду chroot
#    --without-ada
# отключаем сборку и установку большинства статических библиотек
#    --without-normal
# ncurses будет создавать и устанавливать общие привязки C++. это также
# предотвращает создание и установку статических привязок С++
#    --with-cxx-shared
# запретим использовать утилиту strip хоста. Использование инструментов хоста в
# кросс-компилируемых программах может привести к сбою
#    --disable-stripping
# вызываем сборку wide-character libraries (например, libncursesw.so.6.1)
# вместо обычных (libncurses.so.6.1). Эти библиотеки можно использовать как в
# многобайтовых, так и в традиционных 8-битных локалях
#    --enable-widec
./configure                      \
    --prefix=/usr                \
    --host="${LFS_TGT}"          \
    --build="$(./config.guess)"  \
    --mandir=/usr/share/man      \
    --with-manpage-format=normal \
    --with-shared                \
    --without-normal             \
    --with-cxx-shared            \
    --without-debug              \
    --without-ada                \
    --disable-stripping          \
    --enable-widec || exit 1

make || make -j1 || exit 1

# при установке нам нужно передать путь к только что собранной утилите 'tic',
# которая уже способна запускаться в LFS системе и создать базу данных
# терминала без ошибок
#    TIC_PATH="$(pwd)/build/progs/tic"
make TIC_PATH="$(pwd)/build/progs/tic" install DESTDIR="${LFS}"

# библиотека libncurses.so необходима для сборки нескольких пакетов, которые мы
# будем собирать позже
echo "INPUT(-lncursesw)" > "${LFS}/usr/lib/libncurses.so"
