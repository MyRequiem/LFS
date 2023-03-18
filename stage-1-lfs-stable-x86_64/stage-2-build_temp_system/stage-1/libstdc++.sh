#! /bin/bash

PRGNAME="libstdc++"
ARCH_NAME="gcc"

### libstdc++
# Libstdc++ - это стандартная библиотека C++, которая необходима для компиляции
# кода C++ (часть GCC написана на C++). Нам пришлось отложить установку этой
# библиотеки при первом проходе GCC (gcc-pass-1.sh), потому что она зависит от
# glibc, который еще не был установлен

source "$(pwd)/check_environment.sh"                    || exit 1
source "$(pwd)/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

# создадим отдельный каталог для сборки libstdc++
mkdir build
cd build || exit 1

# указывает на использование только что созданного кросс-компилятора вместо
# того, что находится в /usr/bin
#    --host="${LFS_TGT}"
# предотвращает установку include файлов, которые не нужны на данном этапе
#    --disable-libstdcxx-pch
# путь для поиска заголовочных файлов компилятором C++
#    --with-gxx-include-dir="/tools/${LFS_TGT}/include/c++/${GCC_VERSION}"
../"${PRGNAME}-v3/configure"     \
    --host="${LFS_TGT}"          \
    --build="$(../config.guess)" \
    --prefix=/usr                \
    --disable-multilib           \
    --disable-nls                \
    --disable-libstdcxx-pch      \
    --with-gxx-include-dir="/tools/${LFS_TGT}/include/c++/${VERSION}" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"

# удалим libtool архивы (.la), так как они вредны для кросс-компиляции
rm -fv "${LFS}/usr/lib"/lib{stdc++,stdc++fs,supc++}.la
