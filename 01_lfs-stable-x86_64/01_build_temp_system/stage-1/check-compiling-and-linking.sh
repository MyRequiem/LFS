#! /bin/bash

# После установки binutils, gcc и glibc необходимо убедиться, что основные
# функции (компиляция и компоновка) новой цепочки инструментов сборки работают
# должным образом. Для проверки работоспособности создадим простейший C-файл и
# скомпилируем его собранным нами gcc

source "$(pwd)/check_environment.sh" || exit 1

echo ""
echo "--------"
echo "Step: 1"
echo "--------"
echo "# creating simple C-file"
echo "echo 'int main(){}' > dummy.c"

echo 'int main(){}' > dummy.c
echo "ls -l dummy.c"
ls -l dummy.c
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

echo "--------"
echo "Step: 2"
echo "--------"
echo "# compiling source file dummy.c using ${LFS}/tools/bin/${LFS_TGT}-gcc"
echo "# (as a result of compilation, an object file a.out is generated)"
echo "${LFS_TGT}-gcc dummy.c"

"${LFS_TGT}"-gcc dummy.c
echo "ls -l a.out"
ls -l a.out
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

# посмотрим имя динамического компоновщика
echo "--------"
echo "Step: 3"
echo "--------"
echo "# show dynamic linker name"
echo "readelf -l a.out | grep '/ld-linux'"
readelf -l a.out | grep '/ld-linux'
echo ""
echo "# The output should be something like this:"
echo "#     [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]"
echo ""
# если вывод не такой, как указано выше, или вывод не был получен вообще,
# значит что-то не так.

rm -f dummy.c a.out

# теперь, когда наша начальная кросс-инструментальная цепочка инструментов
# сборки (binutils+gcc+glibc) собрана и установлена, завершим установку
# заголовка limits.h. Для этого запустим утилиту mkheaders, предоставленную
# разработчиками GCC
GCC_VERSION="$("${LFS}"/tools/bin/x86_64-lfs-linux-gnu-gcc --version | \
    head -n 1 | rev | cut -d " " -f 1 | rev)"
"${LFS}/tools/libexec/gcc/${LFS_TGT}/${GCC_VERSION}"/install-tools/mkheaders
