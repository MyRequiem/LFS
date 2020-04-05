#! /bin/bash

PRGNAME="ncurses"

### Ncurses
# Библиотека, написанная на языках Си и Ада, предназначенная для управления
# вводом-выводом на терминал. Так же библиотека позволяет задавать экранные
# координаты и цвет выводимых символов. Предоставляет программисту уровень
# абстракции, позволяющий не беспокоиться об аппаратных различиях терминалов и
# писать переносимый код

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/ncurses.html

# Home page: http://www.gnu.org/software/ncurses/
# Download:  http://ftp.gnu.org/gnu/ncurses/ncurses-6.1.tar.gz

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# во время конфигурации gawk должен быть обнаружен первым, вместо mawk
sed -i s/mawk// configure

### Конфигурация
# Ncurses не должен создавать поддержку для компилятора Ada, который может
# присутствовать на хосте, но не будет доступен после входа в среду chroot
#    --without-ada
# вызываем сборку wide-character libraries (например, libncursesw.so.6.1)
# вместо обычных (libncurses.so.6.1). Эти библиотеки можно использовать как в
# многобайтовых, так и в традиционных 8-битных локалях
#    --enable-widec
# установливать свои заголовочные файлы в /tools/include вместо
# /tools/include/ncurses, чтобы другие пакеты могли успешно находить эти
# заголовки
#    --enable-overwrite
./configure         \
    --prefix=/tools \
    --with-shared   \
    --without-debug \
    --without-ada   \
    --enable-widec  \
    --enable-overwrite || exit 1

make || make -j1 || exit 1
make install

# создаем ссылку в /tools/lib libncurses.so -> libncursesw.so
ln -s libncursesw.so /tools/lib/libncurses.so
