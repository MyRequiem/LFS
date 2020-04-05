#! /bin/bash

PRGNAME="gcc"

### GCC
# Пакет содержит коллекцию компиляторов GNU, которая включает компиляторы C и
# C++

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/gcc-pass1.html

# Home page: https://gcc.gnu.org/
# Download:  http://ftp.gnu.org/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.xz

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
tar xvf "${SOURCES}/gmp-${GMP_VER}".tar.?z* || exit 1
mv "gmp-${GMP_VER}" gmp
tar xvf "${SOURCES}/mpfr-${MPFR_VER}".tar.?z* || exit 1
mv "mpfr-${MPFR_VER}" mpfr
tar xvf "${SOURCES}/mpc-${MPC_VER}".tar.?z* || exit 1
mv "mpc-${MPC_VER}" mpc

# изменяем расположение динамического компоновщика GCC по умолчанию на тот,
# который уже установлен в /tools.
#
# Сначала копируем файлы:
#    gcc/config/linux.h        --> gcc/config/linux.h.orig,
#    gcc/config/i386/linux.h   --> gcc/config/i386/linux.h.orig
#    gcc/config/i368/linux64.h --> gcc/config/i368/linux64.h.orig
#
# Затем первый sed добавляет '/tools' к каждому экземпляру '/lib/ld',
# '/lib64/ld' или '/lib32/ld', а второй заменяет жестко закодированные
# экземпляры '/usr'. Затем мы добавляем операторы 'define', которые изменяют
# префикс начального файла по умолчанию. Дале мы используем touch для
# обновления метки времени скопированных файлов. При использовании в сочетании
# с 'cp -u' это предотвращает непредвиденные изменения в исходных файлах в
# случае непреднамеренного запуска команд дважды.
for FILE in gcc/config/{linux,i386/linux{,64}}.h; do
    cp -uv "${FILE}"{,.orig}
    sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
        -e 's@/usr@/tools@g' "${FILE}.orig" > "${FILE}"
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> "${FILE}"
    touch "${FILE}.orig"
done

# установим имя каталога для 64-битных библиотек по умолчанию как 'lib'
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

# документация gcc рекомендует собирать gcc в отдельном каталоге для сборки
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
# локальный префикс - это место в системе, в котором GCC будет искать локально
# установленные include файлы
#    --with-local-prefix=/tools
# по умолчанию GCC ищет системные заголовки в /usr/include.
#    --with-native-system-header-dir=/tools/include
# заставляет GCC статически связывать свои внутренние библиотеки. Мы делаем это,
# чтобы избежать возможных проблем с хост-системой
#    --disable-shared
# Эти ключи отключают поддержку десятичного расширения с плавающей запятой,
# потоков libatomic, libgomp, libquadmath, libssp, libvtv и стандартной
# библиотеки C ++ соответственно. Эти функции не будут компилироваться при
# сборке кросс-компилятора и не нужны для задачи кросс-компиляции временного
# libc.
#    --disable-decimal-float
#    --disable-threads
#    --disable-libatomic,
#    --disable-libgomp
#    --disable-libquadmath
#    --disable-libssp
#    --disable-libvtv,
#    --disable-libstdcxx
# для x86_64 архитектуры LFS еще не поддерживает мультибиблиотечную
# конфигурацию
#    --disable-multilib
# гарантирует, что будут собраны только компиляторы C и C ++. Это единственные
# языки, необходимые сейчас.
#    --enable-languages=c,c++
../configure                                       \
    --target="${LFS_TGT}"                          \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot="${LFS}"                        \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++ || exit 1

make || make -j1 || exit 1
make install
