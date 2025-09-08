#! /bin/bash

PRGNAME="gcc"

### GCC
# Пакет содержит коллекцию компиляторов GNU, который на данный момент будет
# включать только компиляторы C и C++

###
# Это второй проход gcc
###

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# GCC для сборки требует пакеты gmp, mpfr и mpc
GMP_VER=$(echo "${SOURCES}/gmp"-*.tar.?z* | rev | cut -f 3- -d . | \
    cut -f 1 -d - | rev)
MPFR_VER=$(echo "${SOURCES}/mpfr"-*.tar.?z* | rev | cut -f 3- -d . | \
    cut -f 1 -d - | rev)
MPC_VER=$(echo "${SOURCES}/mpc"-*.tar.?z* | rev | cut -f 3- -d . | \
    cut -f 1 -d - | rev)

# распакуем дополнительные пакеты gmp, mpfr и mpc и переименуем директории с
# исходными кодами в соответствии с названиями самих пакетов
tar xvf "${SOURCES}/gmp-${GMP_VER}".tar.?z* || exit 1
mv "gmp-${GMP_VER}" gmp
tar xvf "${SOURCES}/mpfr-${MPFR_VER}".tar.?z* || exit 1
mv "mpfr-${MPFR_VER}" mpfr
tar xvf "${SOURCES}/mpc-${MPC_VER}".tar.?z* || exit 1
mv "mpc-${MPC_VER}" mpc

# установим имя каталога для 64-битных библиотек по умолчанию как 'lib'
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

# переопределим правило сборки заголовков libgcc и libstdc++, чтобы разрешить
# сборку этих библиотек с поддержкой потоков POSIX
sed '/thread_header =/s/@.*@/gthr-posix.h/' \
    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in || exit 1

# документация gcc рекомендует собирать gcc в отдельном каталоге
mkdir build
cd build || exit 1

# отключаем локализацию, поскольку i18n на данном этапе нам не требуется
#    --disable-nls
# для x86_64 архитектуры LFS пока не поддерживает мультибиблиотечную
# конфигурацию
#    --disable-multilib
# отключачаем поддержку десятичного расширения с плавающей запятой, потоков
# libatomic, libgomp, libquadmath, libssp, libvtv и стандартной библиотеки C++
# соответственно, т.к. эти функции не нужны для кросс-компиляции временного
# libc
#    --disable-libatomic
#    --disable-libgomp
#    --disable-libquadmath
#    --disable-libssp
#    --disable-libvtv
# отключаем runtime библиотеки GCC sanitizer, которые не нужны для временной
# установки. В gcc-pass-1.sh мы это делали с помощью параметра
# --disable-libstdcxx, теперь мы можем явно указать
#    --disable-libsanitizer
# собираем только необходимые на данный момент компиляторы C и C++
#    --enable-languages=c,c++
# разрешить libstdc++ использовать общий libgcc, созданный на этом этапе,
# вместо статической версии, созданной при первой сборке GCC. Это необходимо
# для поддержки обработки исключений C++
#    LDFLAGS_FOR_TARGET=...
../configure                      \
    --build="$(../config.guess)"  \
    --host="${LFS_TGT}"           \
    --target="${LFS_TGT}"         \
    --prefix=/usr                 \
    --with-build-sysroot="${LFS}" \
    --enable-default-pie          \
    --enable-default-ssp          \
    --disable-nls                 \
    --disable-multilib            \
    --disable-libatomic           \
    --disable-libgomp             \
    --disable-libquadmath         \
    --disable-libsanitizer        \
    --disable-libssp              \
    --disable-libvtv              \
    --enable-languages=c,c++      \
    LDFLAGS_FOR_TARGET=-L"${PWD}/${LFS_TGT}/libgcc" || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install

# создадим ссылку в /usr/bin/
#    cc -> gcc
# для универсальности и совместимости со всеми UNIX-системами, т.к. многие
# программы и скрипты запускают 'cc' вместо 'gcc'
ln -svf gcc "${LFS}/usr/bin/cc"
