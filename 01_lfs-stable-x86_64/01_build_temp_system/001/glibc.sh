#! /bin/bash

PRGNAME="glibc"
GCC_VERSION="10.2.0"

### Glibc
# Пакет Glibc содержит основную библиотеку C, которая предоставляет основные
# процедуры для выделения памяти, поиска в каталогах, открытия/закрытия,
# чтения/записи файлов, обработки строк, сопоставления с шаблонами, арифметики
# и так далее.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/glibc.html

# Home page: http://www.gnu.org/software/libc/

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# ссылка для соответствия требованиям LSB
# $LFS/tools/lib64/ld-linux-x86-64.so.2 -> ../lib/ld-linux-x86-64.so.2
ln -sfv ../lib/ld-linux-x86-64.so.2 /tools/lib64

# ссылка для правильной работы загрузчика динамических библиотек
# $LFS/tools/lib64/ld-lsb-x86-64.so.3 -> ../lib/ld-linux-x86-64.so.2
ln -sfv ../lib/ld-linux-x86-64.so.2 /tools/lib64/ld-lsb-x86-64.so.3

# некоторые программы Glibc используют несовместимый с FHS каталог /var/db для
# хранения своих run-time данных. Применим патч, чтобы такие программы
# сохраняли свои run-time данные в FHS-совместимых местоположениях
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-${VERSION}-fhs-1.patch" || exit 1

# документация glibc рекомендует собирать glibc в отдельном каталоге
mkdir build
cd build || exit 1

../configure                      \
    --prefix=/tools               \
    --host="${LFS_TGT}"           \
    --enable-kernel=3.2           \
    --with-headers=/tools/include \
    --build="$(../scripts/config.guess)" || exit 1

make || make -j1 || exit 1
make install

# теперь, когда наша начальная кросс-инструментальная цепочка инструментов
# (gcc+glibc) создана, завершим установку заголовка limits.h. Для этого
# запустим утилиту, предоставленную разработчиками GCC
/tools/libexec/gcc/"${LFS_TGT}/${GCC_VERSION}"/install-tools/mkheaders
