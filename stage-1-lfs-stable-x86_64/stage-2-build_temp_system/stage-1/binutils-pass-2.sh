#! /bin/bash

PRGNAME="binutils"

### Binutils
# Пакет содержит компоновщик, ассемблер и другие инструменты для работы с
# объектными файлами

###
# Это второй проход binutils
###

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# Binutils поставляет устаревшую копию libtool в архиве, в которой не хватает
# поддержки sysroot, поэтому созданные двоичные файлы будут ошибочно связаны с
# библиотеками хоста. Обойдем эту проблему:
sed '6009s/$add_dir//' -i ltmain.sh

# документация Binutils рекомендует собирать binutils в отдельном каталоге
mkdir build
cd build || exit 1

# собирать libbfd как shared библиотеку
#    --enable-shared
# включает поддержку 64-битной версии (на хостах с более узким размером слова).
# Может не понадобиться для 64-битных система, но вреда не причинит
#    --enable-64-bit-bfd
../configure                   \
    --prefix=/usr              \
    --host="${LFS_TGT}"        \
    --disable-nls              \
    --enable-shared            \
    --enable-gprofng=no        \
    --disable-werror           \
    --enable-64-bit-bfd        \
    --build="$(../config.guess)" || exit 1

make || make -j1 || exit 1
make install DESTDIR="${LFS}"

# удалим libtool архивы, поскольку они вредны для кросс-компиляции, а так же
# удалим ненужные статические библиотеки
rm -fv "${LFS}/usr/lib"/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
