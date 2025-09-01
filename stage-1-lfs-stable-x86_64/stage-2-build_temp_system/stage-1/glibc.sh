#! /bin/bash

PRGNAME="glibc"

### Glibc
# Пакет Glibc содержит основную библиотеку C, которая предоставляет основные
# процедуры для выделения памяти, поиска в каталогах, открытия/закрытия,
# чтения/записи файлов, обработки строк, сопоставления с шаблонами, арифметики
# и так далее.

source "$(pwd)/check_environment.sh"                  || exit 1
source "$(pwd)/unpack_source_archive.sh" "${PRGNAME}" || exit 1

# ссылка для соответствия требованиям LSB
# /mnt/lfs/lib64/ld-linux-x86-64.so.2 -> ../lib/ld-linux-x86-64.so.2
ln -sfv ../lib/ld-linux-x86-64.so.2 "${LFS}/lib64"

# ссылка для правильной работы загрузчика динамических библиотек
# /mnt/lfs/lib64/ld-lsb-x86-64.so.3 -> ../lib/ld-linux-x86-64.so.2
ln -sfv ../lib/ld-linux-x86-64.so.2 "${LFS}/lib64/ld-lsb-x86-64.so.3"

# некоторые программы Glibc используют несовместимый с FHS каталог /var/db для
# хранения своих run-time данных. Применим патч, чтобы такие программы
# сохраняли свои run-time данные в FHS-совместимых каталогах
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-${VERSION}-fhs-1.patch" || exit 1

# документация glibc рекомендует собирать glibc в отдельном каталоге
mkdir build
cd build || exit 1

# утилиты ldconfig и sln будут установлены в /usr/sbin:
echo "rootsbindir=/usr/sbin" > configparms

# комбинированный эффект этих двух параметров заключается в том, что система
# сборки Glibc сама настраивается для кросс-компиляции, используя кросс-линкер
# и кросс-компилятор в /mnt/lfs/tools
#    --host="${LFS_TGT}"
#    --build="$(../scripts/config.guess)"
# не создавать name service cache daemon (nscd), который больше не используется
#    --disable-nscd
# устанавливать библиотеки в /mnt/lfs/usr/lib вместо /mnt/lfs/lib64 по
# умолчанию для 64-битных машин
#    libc_cv_slibdir=/usr/lib
# указывает Glibc скомпилировать библиотеку с поддержкой ядер Linux >=5.4
# (более ранние версии поддерживаться не будут)
#    --enable-kernel=5.4

###
# NOTE: на этапе сборки могут появлятся следующие предупреждения:
###
#    configure: WARNING:
#    *** These auxiliary programs are missing or
#    *** incompatible versions: msgfmt
#    *** some features will be disabled.
#    *** Check the INSTALL file for required versions.
#
# отсутствующая или несовместимая утилита msgfmt является частью пакета
# Gettext, который еще не установлен и обычно такие сообщения безвредны

../configure                             \
    --prefix=/usr                        \
    --host="${LFS_TGT}"                  \
    --build="$(../scripts/config.guess)" \
    --disable-nscd                       \
    libc_cv_slibdir=/usr/lib             \
    --enable-kernel=5.4 || exit 1

make || make -j1 || exit 1
make DESTDIR="${LFS}" install

# исправим жестко запрограммированный путь к исполняемому загрузчику в скрипте
# ldd
sed '/RTLDLIST=/s@/usr@@g' -i "${LFS}/usr/bin/ldd"
