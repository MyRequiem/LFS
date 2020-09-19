#! /bin/bash

PRGNAME="libstdc++"
ARCH_NAME="gcc"

### libstdc++
# Libstdc++ - это стандартная библиотека C++, которая необходима для компиляции
# кода C++. При сборке gcc-pass-2 нам пришлось отложить установку этой
# библиотеки, потому что для ее компиляции не было подходящего компилятора. Мы
# бы не могли использовать собранный нами GCC, потому что он мог работать
# только в chroot среде.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter07/gcc-libstdc++-pass2.html

# Home page: https://gcc.gnu.org/

###
# Это второй проход libstdc++
###

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# создадим ссылку в каталоге libgcc/ дерева исходного кода GCC
#    gthr-default.h -> gthr-posix.h
ln -s gthr-posix.h libgcc/gthr-default.h

# создадим отдельный каталог для сборки libstdc++
mkdir build
cd build || exit 1

# эти флаги передаются Makefile верхнего уровня при выполнении полной сборки
# GCC
#    CXXFLAGS="-g -O2 -D_GNU_SOURCE"
# предотвращает установку include файлов, которые не нужны на данном этапе
#    --disable-libstdcxx-pch
../"${PRGNAME}-v3/configure"        \
    CXXFLAGS="-g -O2 -D_GNU_SOURCE" \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --host=x86_64-lfs-linux-gnu     \
    --disable-libstdcxx-pch || exit 1

make || make -j1 || exit 1
make install
