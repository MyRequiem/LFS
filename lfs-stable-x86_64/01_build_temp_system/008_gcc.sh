#! /bin/bash

PRGNAME="gcc"

### GCC
# Пакет содержит коллекцию компиляторов GNU, которая включает компиляторы C и
# C++

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/gcc-pass2.html

# Home page: https://gcc.gnu.org/
# Download:  http://ftp.gnu.org/gnu/gcc/gcc-9.2.0/gcc-9.2.0.tar.xz

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

# Первая сборка GCC установила несколько внутренних системных заголовков. Один
# из них limits.h включает в себя соответствующий системный заголовок limits.h,
# в данном случае это /tools/include/limits.h. Тем не менее, во время первой
# сборки GCC /tools/include/limits.h не существовало, поэтому внутренний
# заголовок, который установлен на данный момент не полный, и не включает в
# себя расширенные функции системного заголовка. Этого было достаточно для
# сборки временного libc, но для вторичной сборки GCC требуется полный
# внутренний заголовок. Поэтому создадим его:
LIMITS="include-fixed/limits.h"
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
    "$(dirname "$("${LFS_TGT}"-gcc -print-libgcc-file-name)")/${LIMITS}"

# изменяем расположение динамического компоновщика GCC по умолчанию на тот,
# который уже установлен в /tools
#
# Сначала сохраняем оригиналы заголовков:
#    gcc/config/linux.h        --> gcc/config/linux.h.orig,
#    gcc/config/i386/linux.h   --> gcc/config/i386/linux.h.orig
#    gcc/config/i368/linux64.h --> gcc/config/i368/linux64.h.orig
#
# Затем первое регулярно выражение в sed добавляет '/tools' к каждому
# экземпляру '/lib/ld', '/lib64/ld' или '/lib32/ld', а второе заменяет жестко
# закодированные экземпляры '/usr' на '/tools'. Затем мы добавляем операторы
# 'define', которые изменяют префикс начального файла по умолчанию. Дале мы
# используем touch для обновления метки времени скопированных файлов. При
# использовании в сочетании с 'cp -u' это предотвращает непредвиденные
# изменения в исходных файлах в случае непреднамеренного запуска команд дважды.
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
# создаем компиляторы для C и C++
#    --enable-languages=c,c++
# не создаем предварительно скомпилированный заголовок (PCH) для libstdc++. Он
# огромный и нам не нужен
#    --disable-libstdcxx-pch
# для обычной сборки GCC по умолчанию используется сборка "bootstrap", и как
# итог для полной сборки GCC приходится его компилировать несколько раз, т.е.
# используются программы, скомпилированные в первом проходе, чтобы
# компилировать себя во второй раз, а затем и в третий раз. Затем сравниваются
# второй и третий проход, чтобы убедиться, что они могут воспроизводиться
# безупречно. Однако метод сборки LFS должен обеспечивать надежный компилятор
# без необходимости каждый раз создавать "bootstrap"
#    --disable-bootstrap
CC="${LFS_TGT}-gcc"                                \
CXX="${LFS_TGT}-g++"                               \
AR="${LFS_TGT}-ar"                                 \
RANLIB="${LFS_TGT}-ranlib"                         \
../configure                                       \
    --prefix=/tools                                \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++                       \
    --disable-libstdcxx-pch                        \
    --disable-multilib                             \
    --disable-bootstrap                            \
    --disable-libgomp || exit 1

make || make -j1 || exit 1
make install

# создаем символическую ссылку в /tools/bin сс -> gcc
ln -sv gcc /tools/bin/cc
