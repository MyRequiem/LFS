#! /bin/bash

PRGNAME="gcc"

### GCC
# Пакет содержит коллекцию компиляторов GNU, которая включает компиляторы C и
# C++

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/gcc-pass1.html

# Home page: https://gcc.gnu.org/

###
# Это первый проход gcc
###

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# GCC для сборки требует пакеты gmp, mpfr и mpc
# http://ftp.gnu.org/gnu/gmp/gmp-6.2.0.tar.xz
# http://www.mpfr.org/mpfr-4.0.2/mpfr-4.0.2.tar.xz
# https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
GMP_VER=$(echo "${SOURCES}/gmp"-*.tar.?z* | rev | cut -f 3- -d . | \
    cut -f 1 -d - | rev)
MPFR_VER=$(echo "${SOURCES}/mpfr"-*.tar.?z* | rev | cut -f 3- -d . | \
    cut -f 1 -d - | rev)
MPC_VER=$(echo "${SOURCES}/mpc"-*.tar.?z* | rev | cut -f 3- -d . | \
    cut -f 1 -d - | rev)

# распакуем дополнительные пакеты gmp, mpfr и mpc и переименуем директории
# с исходными кодами в соответствии с названиями самих пакетов
tar xvf "${SOURCES}/gmp-${GMP_VER}".tar.?z*   || exit 1
mv "gmp-${GMP_VER}" gmp
tar xvf "${SOURCES}/mpfr-${MPFR_VER}".tar.?z* || exit 1
mv "mpfr-${MPFR_VER}" mpfr
tar xvf "${SOURCES}/mpc-${MPC_VER}".tar.?z*   || exit 1
mv "mpc-${MPC_VER}" mpc

# установим имя каталога для 64-битных библиотек по умолчанию как 'lib'
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

# документация gcc рекомендует собирать gcc в отдельном каталоге
mkdir build
cd build || exit 1

### Конфигурация
# поскольку рабочая библиотека C еще не доступна, это гарантирует, что при
# сборке libgcc определена константа injit_libc. Это предотвращает компиляцию
# любого кода, который требует поддержки libc.
#    --with-newlib
# при создании полного кросс-компилятора GCC требуются стандартные заголовки,
# совместимые с целевой системой. Для наших целей эти заголовки не понадобятся,
# поэтому не позволяем GCC искать их.
#    --without-headers
# использовать некоторые внутренние структуры данных, которые необходимы, но не
# могут быть обнаружены при построении кросс-компилятора
#    --enable-initfini-array
# локальный префикс - это место в системе, в котором GCC будет искать локально
# по умолчанию GCC ищет системные заголовки в /usr/include.
#    --with-native-system-header-dir=/tools/include
# заставляет GCC статически связывать свои внутренние библиотеки. Мы делаем это,
# чтобы избежать возможных проблем с хост-системой
#    --disable-shared
# для x86_64 архитектуры LFS пока не поддерживает мультибиблиотечную
# конфигурацию
#    --disable-multilib
# Эти ключи отключают поддержку десятичного расширения с плавающей запятой,
# потоков libatomic, libgomp, libquadmath, libssp, libvtv и стандартной
# библиотеки C ++ соответственно. Эти функции не будут компилироваться при
# сборке кросс-компилятора и не нужны для кросс-компиляции временного Glibc
#    --disable-decimal-float
#    --disable-threads
#    --disable-libatomic
#    --disable-libgomp
#    --disable-libquadmath
#    --disable-libssp
#    --disable-libvtv
#    --disable-libstdcxx
# собираем только необходимые на данный момент компиляторы C и C++
#    --enable-languages=c,c++
../configure                   \
    --target="${LFS_TGT}"      \
    --prefix=/tools            \
    --with-glibc-version=2.11  \
    --with-sysroot="${LFS}"    \
    --with-newlib              \
    --without-headers          \
    --enable-initfini-array    \
    --disable-nls              \
    --disable-shared           \
    --disable-multilib         \
    --disable-decimal-float    \
    --disable-threads          \
    --disable-libatomic        \
    --disable-libgomp          \
    --disable-libquadmath      \
    --disable-libssp           \
    --disable-libvtv           \
    --disable-libstdcxx        \
    --enable-languages=c,c++ || exit 1

make || make -j1 || exit 1
make install

# эта сборка GCC установила несколько внутренних системных заголовков. Один из
# них limits.h, который в свою очередь будет включать соответствующие системные
# limits.h заголовки, в данном случае /usr/include/limits.h Однако на данный
# момент в LFS системе /usr/include/limits.h не существует, поэтому внутренний
# заголовок который был только что установлен, является частичным автономным
# файлом и не включает расширенные функции системного заголовка. Такая ситуация
# подходит для сборки glibc, но полный внутренний заголовок понадобится позже,
# поэтому создадим полную версию внутреннего заголовка:
cd ..
GCC_DIR_NAME="$(dirname "$("${LFS_TGT}"-gcc -print-libgcc-file-name)")"
cat gcc/limitx.h  \
    gcc/glimits.h \
    gcc/limity.h > "${GCC_DIR_NAME}/install-tools/include/limits.h"
