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
echo ""

echo "--------"
echo "Step: 2"
echo "--------"
echo "# compiling source file dummy.c using /tools/bin/${LFS_TGT}-gcc"
echo "# (as a result of compilation, an object file a.out is generated)"
echo "${LFS_TGT}-gcc dummy.c"

"${LFS_TGT}"-gcc dummy.c
echo ""

# посмотрим имя динамического компоновщика (см. 000_info)
echo "--------"
echo "Step: 3"
echo "--------"
echo "# show dynamic linker name"
echo "readelf -l a.out | grep ': /tools'"
readelf -l a.out | grep ': /tools'
echo ""
echo "# The output should be something like this:"
echo "#     [Requesting program interpreter: /tools/lib64/ld-linux-x86-64.so.2]"
echo ""
# если вывод не такой, как указано выше, или вывод не был получен вообще,
# значит что-то не так.

rm -f dummy.c a.out
