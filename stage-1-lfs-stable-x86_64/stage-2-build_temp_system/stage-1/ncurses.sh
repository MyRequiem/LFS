#! /bin/bash

PRGNAME="ncurses"

### Ncurses
# Библиотека, написанная на языках Си и Ада, предназначенная для управления
# вводом-выводом на терминал. Так же библиотека позволяет задавать экранные
# координаты и цвет выводимых символов. Предоставляет программисту уровень
# абстракции, позволяющий не беспокоиться об аппаратных различиях терминалов и
# писать переносимый код

source "$(pwd)/check_environment.sh" || exit 1

SOURCES="${LFS}/sources"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.t?z" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 2- | cut -d - -f 1,2 | rev)"

BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}-${VERSION}"

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.t?z || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# соберем утилиту 'tic'
mkdir build
pushd build       || exit 1
../configure            \
    --prefix=$LFS/tools \
    AWK=gawk      || exit 1
make -C include   || exit 1
make -C progs tic || exit 1
popd              || exit 1

# не сжимать man-страницы в .gz
#    --with-manpage-format=normal
# отключаем сборку и установку большинства статических библиотек
#    --without-normal
# ncurses будет создавать и устанавливать общие привязки C++. это также
# предотвращает создание и установку статических привязок С++
#    --with-cxx-shared
# Ncurses не должен создавать поддержку для компилятора Ada, который может
# присутствовать на хосте, но не будет доступен после входа в среду chroot
#    --without-ada
# запретим использовать утилиту strip хоста. Использование инструментов хоста в
# кросс-компилируемых программах может привести к сбою
#    --disable-stripping
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
    AWK=gawk || exit 1

make || make -j1 || exit 1

make DESTDIR="${LFS}" install

# библиотека libncurses.so необходима для нескольких пакетов в LFS, поэтому
# создадим ссылку в /usr/lib/
#    libncurses.so -> libncursesw.so
# чтобы использовать libncursesw.so в качестве замены
ln -sv libncursesw.so "${LFS}/usr/lib/libncurses.so"

# заголовочный файл curs.h содержит определения различных структур данных
# ncurses. с разными определениями макросов препроцессора могут использоваться
# два разных набора определений структуры данных: 8-битное определение
# совместимо с libncurses.so, а определение расширенных символов совместимо с
# libncursesw.so. Поскольку мы используем libncursesw.so вместо libncurses.so,
# отредактируем заголовок curses.h, чтобы он всегда использовал определение
# структуры данных расширенных символов, совместимое с libncursesw.so
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i "${LFS}/usr/include/curses.h"
