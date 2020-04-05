#! /bin/bash

PRGNAME="libstdc++"

### libstdc++
# Libstdc ++ - это стандартная библиотека C++, которая необходима для
# компиляции кода C++ (часть GCC написана на C++). Нам пришлось отложить
# установку этой библиотеки при первом проходе GCC (002_gcc.sh), потому что
# она зависит от glibc, который еще не был собран в /tools.

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/gcc-libstdc++.html

# Home page: https://gcc.gnu.org/
# Download: http://ftp.gnu.org/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.xz

source "$(pwd)/check_environment.sh"           || exit 1
source "$(pwd)/unpack_source_archive.sh" "gcc" || exit 1

# создадим отдельный каталог для сборки libstdc++
mkdir build
cd build || exit 1

# указывает на использование только что созданного кросс-компилятора вместо
# того, что был в /usr/bin
#    --host="${LFS_TGT}"
# поскольку мы еще не создали библиотеку потоков C, C++ также не может быть
# собран
#    --disable-libstdcxx-threads
# предотвращает установку include файлов, которые не нужны на данном этапе
#    --disable-libstdcxx-pch
# путь для поиска заголовочных файлов компилятором C++
#    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/9.2.0
../${PRGNAME}-v3/configure          \
    --host="${LFS_TGT}"             \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir="/tools/${LFS_TGT}/include/c++/${VERSION}" || exit 1

make || make -j1 || exit 1
make install
