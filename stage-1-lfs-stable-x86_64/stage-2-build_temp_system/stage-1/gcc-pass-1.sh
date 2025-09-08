#! /bin/bash

PRGNAME="gcc"

### GCC
# Пакет содержит коллекцию компиляторов GNU, который на данный момент будет
# включать только компиляторы C и C++

###
# Это первый проход gcc
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

# версия Glibc, которая будет использоваться в LFS
#    --with-glibc-version=2.42
# поскольку рабочая библиотека C еще не доступна, это гарантирует, что при
# сборке libgcc определена константа injit_libc. Это предотвращает компиляцию
# любого кода, который требует поддержки libc.
#    --with-newlib
# при создании полного кросс-компилятора GCC требуются стандартные заголовки,
# совместимые с целевой системой. Для наших целей эти заголовки не понадобятся,
# поэтому не позволяем GCC искать их.
#    --without-headers
# отключаем локализацию, поскольку i18n на данном этапе нам не требуется
#    --disable-nls
# заставляет GCC статически связывать свои внутренние библиотеки. Мы делаем это
# для того, чтобы избежать возможных проблем с библиотеками хост-системы
#    --disable-shared
# для x86_64 архитектуры LFS пока не поддерживает мультибиблиотечную
# конфигурацию
#    --disable-multilib
# отключачаем поддержку десятичного расширения с плавающей запятой, потоков
# libatomic, libgomp, libquadmath, libssp, libvtv и стандартной библиотеки C++
# соответственно, т.к. эти функции не нужны для кросс-компиляции временного
# libc
#    --disable-threads
#    --disable-libatomic
#    --disable-libgomp
#    --disable-libquadmath
#    --disable-libssp
#    --disable-libvtv
#    --disable-libstdcxx
# собираем только необходимые на данный момент компиляторы C и C++
#    --enable-languages=c,c++
../configure                  \
    --target="${LFS_TGT}"     \
    --prefix="${LFS}/tools"   \
    --with-glibc-version=2.42 \
    --with-sysroot="${LFS}"   \
    --with-newlib             \
    --without-headers         \
    --enable-default-pie      \
    --enable-default-ssp      \
    --disable-nls             \
    --disable-shared          \
    --disable-multilib        \
    --disable-threads         \
    --disable-libatomic       \
    --disable-libgomp         \
    --disable-libquadmath     \
    --disable-libssp          \
    --disable-libvtv          \
    --disable-libstdcxx       \
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
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
    "$(dirname "$("${LFS_TGT}"-gcc -print-libgcc-file-name)")"/include/limits.h
