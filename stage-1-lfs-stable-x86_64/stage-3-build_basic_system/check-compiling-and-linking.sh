#! /bin/bash

# ROOT="/"
# source "${ROOT}check_environment.sh" || exit 1

# Теперь, когда наша конечная цепочка инструментов (binutils+glibc+gcc)
# полностью готова, важно снова убедиться, что компиляция и компоновка будут
# работать должным образом.

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
echo "# compiling source file dummy.c using 'cc' (link to gcc)'"
echo "# (as a result of compilation, an object file a.out is generated)"
echo "cc dummy.c -v -Wl,--verbose &> dummy.log"
cc dummy.c -v -Wl,--verbose &> dummy.log
echo "ls -l a.out"
ls -l a.out
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

echo "--------"
echo "Step: 3"
echo "--------"
# посмотрим имя динамического компоновщика
echo "# show dynamic linker name"
echo "readelf -l a.out | grep ': /lib'"
readelf -l a.out | grep ': /lib'
echo ""
echo "# The output should be something like this:"
echo "#     [Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]"
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""
# если вывод не такой, как указано выше, или вывод не был получен вообще,
# значит что-то не так.

echo "--------"
echo "Step: 4"
echo "--------"
VERSION="$(gcc --version | head -n 1 | cut -d " " -f 3)"
# проверим настройки для стартовых файлов
# /usr/lib/Scrt1.o
# /usr/lib/crti.o
# /usr/lib/crtn.o
echo "# make sure that we're setup to use the correct start files"
echo "grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log"
grep -E -o '/usr/lib.*/S?crt[1in].*succeeded' dummy.log
echo ""
echo "# The output should be something like this:"
echo "/usr/lib/gcc/x86_64-pc-linux-gnu/${VERSION}/../../../../lib/Scrt1.o succeeded"
echo "/usr/lib/gcc/x86_64-pc-linux-gnu/${VERSION}/../../../../lib/crti.o succeeded"
echo "/usr/lib/gcc/x86_64-pc-linux-gnu/${VERSION}/../../../../lib/crtn.o succeeded"
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""
# В зависимости от архитектуры машины вывод может незначительно отличатся,
# обычно это имя каталога после /usr/lib/gcc/. Здесь важно обратить внимание на
# то, что gcc нашел все три файла crt*.o в каталоге /usr/lib/

echo "--------"
echo "Step: 5"
echo "--------"
# убедимся, что компилятор ищет правильные заголовочные файлы
echo "# verify that the compiler is searching for the correct header files"
echo "grep -B4 '^ /usr/include' dummy.log"
grep -B4 '^ /usr/include' dummy.log
echo ""
echo "# The output should be something like this:"
echo "#include <...> search starts here:"
echo " /usr/lib/gcc/x86_64-pc-linux-gnu/${VERSION}/include"
echo " /usr/local/include"
echo " /usr/lib/gcc/x86_64-pc-linux-gnu/${VERSION}/include-fixed"
echo " /usr/include"
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

echo "--------"
echo "Step: 6"
echo "--------"
# убедимся, что новый компоновщик использует правильные пути для поиска
echo "verify that the new linker is being used with the correct search paths"
printf "grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\\\n|g'\n"
grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'
echo ""
# ссылки на пути, в которых есть компоненты с -linux-gnu, должны
# игнорироваться, но весь остальной вывод должен быть такой
echo "# The output should be something like this:"
echo 'SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib64")'
echo 'SEARCH_DIR("/usr/local/lib64")'
echo 'SEARCH_DIR("/lib64")'
echo 'SEARCH_DIR("/usr/lib64")'
echo 'SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib")'
echo 'SEARCH_DIR("/usr/local/lib")'
echo 'SEARCH_DIR("/lib")'
echo 'SEARCH_DIR("/usr/lib")'
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

echo "--------"
echo "Step: 7"
echo "--------"
# убедимся, что мы используем правильный libc
echo "# make sure that we're using the correct libc"
echo 'grep "/lib.*/libc.so.6 " dummy.log'
grep "/lib.*/libc.so.6 " dummy.log
echo ""
echo "# The output should be something like this:"
echo "attempt to open /usr/lib/libc.so.6 succeeded"
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

echo "--------"
echo "Step: 8"
echo "--------"
# наконец, убедимся, что GCC использует правильный динамический компоновщик
echo "# make sure GCC is using the correct dynamic linker"
echo "grep found dummy.log"
grep found dummy.log
echo ""
echo "# The output should be something like this:"
echo "found ld-linux-x86-64.so.2 at /usr/lib/ld-linux-x86-64.so.2"
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""
# если выходные данные не отображаются, как показано выше, или не получены
# вообще, значит, что-то серьезно не так. Любые проблемы должны быть решены,
# прежде чем продолжить процесс сборки.

# очистим созданные нами тестовые файлы
rm -fv dummy.c a.out dummy.log
