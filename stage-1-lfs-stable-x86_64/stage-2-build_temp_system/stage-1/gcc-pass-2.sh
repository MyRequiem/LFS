#! /bin/bash

PRGNAME="gcc"

### GCC
# Пакет содержит коллекцию компиляторов GNU, который на данный момент будет
# включать только компиляторы C и C++

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/gcc-pass2.html

# Home page: https://gcc.gnu.org/

###
# Это второй проход gcc
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

# документация gcc рекомендует собирать gcc в отдельном каталоге
mkdir build
cd build || exit 1

# создадим ссылку в каталоге сборки, позволяющую собирать libgcc с поддержкой
# потоков posix
#    x86_64-lfs-linux-gnu/libgcc/gthr-default.h -> ../../../libgcc/gthr-posix.h
mkdir -pv "${LFS_TGT}/libgcc"
ln -s ../../../libgcc/gthr-posix.h "${LFS_TGT}/libgcc/gthr-default.h"

# эта опция автоматически включается при сборке native компилятора, но здесь мы
# используем кросс-компилятор, поэтому нам нужно явно установить эту опцию
#    --enable-initfini-array
# обычно использование параметра '--host' гарантирует, что кросс-компилятор
# используется для сборки GCC, и этот компилятор знает, что он должен искать
# заголовки и библиотеки в /mnt/lfs Но система сборки GCC использует и другие
# инструменты, которые не знают об этом, поэтому явно указываем, что нужные
# файлы нужно искать не на хосте а в /mnt/lfs
#    --with-build-sysroot="${LFS}"
../configure                      \
    --build="$(../config.guess)"  \
    --host="${LFS_TGT}"           \
    --prefix=/usr                 \
    --enable-initfini-array       \
    --disable-nls                 \
    --disable-multilib            \
    --disable-decimal-float       \
    --disable-libatomic           \
    --disable-libgomp             \
    --disable-libquadmath         \
    --disable-libssp              \
    --disable-libvtv              \
    --disable-libstdcxx           \
    --enable-languages=c,c++      \
    --with-build-sysroot="${LFS}" \
    CC_FOR_TARGET="${LFS_TGT}-gcc" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"

# создадим ссылку cc -> gcc в /mnt/lfs/usr/bin/, т.к. многие программы и
# скрипты запускают 'cc' вместо 'gcc' для универсальности и совместимости со
# всеми UNIX-системами
ln -svf gcc "${LFS}/usr/bin/cc"
