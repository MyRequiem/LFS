#! /bin/bash

# После установки binutils, gcc и glibc необходимо убедиться, что основные
# функции (компиляция и компоновка) новой цепочки инструментов сборки работают
# должным образом

source "$(pwd)/check_environment.sh" || exit 1

echo ""
echo "--------"
echo "Step: 1"
echo "--------"
echo "# creating a.out"
echo "echo 'int main(){}' | $LFS_TGT-gcc -xc -"
echo 'int main(){}' | "${LFS_TGT}-gcc" -xc -
echo "ls -l a.out"
ls -l a.out
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

echo "--------"
echo "Step: 2"
echo "--------"
# посмотрим имя динамического компоновщика
echo "# show dynamic linker name"
echo "readelf -l a.out | grep ld-linux"
readelf -l a.out | grep ld-linux
echo ""
echo "# The output should be something like this:"
echo "#     [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]"
echo ""
# если вывод не такой, как указано выше, или вывод не был получен вообще,
# значит что-то не так.

rm -f a.out
