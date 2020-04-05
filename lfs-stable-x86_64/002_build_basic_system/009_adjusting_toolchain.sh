#! /bin/bash

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

# Теперь библиотеки C окончательно установлены, и пришло время настроить набор
# временных инструментов /tools так, чтобы он связывал любую вновь
# скомпилированную программу с этими новыми библиотеками. Сначала создадим
# резервную копию компоновщика /tools и заменим его на скорректированный
# компоновщик, который мы создавали ранее. Мы также создадим ссылку на его
# аналог /tools/x86_64-pc-linux-gnu в /bin
mv -v  /tools/bin/{ld,ld-old}
mv -v  /tools/"$(uname -m)-pc-linux-gnu/bin"/{ld,ld-old}
mv -v  /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld "/tools/$(uname -m)-pc-linux-gnu/bin/ld"

# изменим файл спецификаций GCC так, чтобы он указывал на новый динамический
# компоновщик. Простое удаление всех подстрок '/tools' в путях должно дать нам
# правильный путь к динамическому компоновщику. Также настроим файл specs так,
# чтобы GCC знал, где найти правильные заголовки и стартовые файлы Glibc.
# Рекомендуется визуально проверить файл спецификаций, чтобы убедиться, что
# предполагаемое изменение действительно было сделано.
gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    "$(dirname "$(gcc --print-libgcc-file-name)")"/specs

# на этом этапе необходимо убедиться, что основные функции (компиляция и
# линковка) настроенного набора инструментов работают должным образом
echo ""
echo "--------"
echo "Step: 1"
echo "--------"
echo "# creating simple C-file"
echo "echo 'int main(){}' > dummy.c"

echo 'int main(){}' > dummy.c
echo ""

echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

echo "--------"
echo "Step: 2"
echo "--------"
echo "# compiling source file dummy.c using /tools/bin/cc"
echo "# (as a result of compilation, an object file a.out is generated)"
echo "cc dummy.c -v -Wl,--verbose &> dummy.log"

cc dummy.c -v -Wl,--verbose &> dummy.log
echo ""

echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

echo "--------"
echo "Step: 3"
echo "--------"
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

# если вывод не показан, как указано выше, или вывод не был получен вообще,
# значит что-то не так

# проверим настройки для стартовых файлов
# /usr/lib/crt1.o
# /usr/lib/crti.o
# /usr/lib/crtn.o
echo "--------"
echo "Step: 4"
echo "--------"
echo "# make sure that we're setup to use the correct start files"
echo "grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log"

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
echo ""

echo "# The output should be something like this:"
echo "/usr/lib/../lib/crt1.o succeeded"
echo "/usr/lib/../lib/crti.o succeeded"
echo "/usr/lib/../lib/crtn.o succeeded"
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

# убедимся, что компилятор ищет правильные заголовочные файлы
echo "--------"
echo "Step: 5"
echo "--------"
echo "# verify that the compiler is searching for the correct header files"
echo "grep -B1 '^ /usr/include' dummy.log"

grep -B1 '^ /usr/include' dummy.log
echo ""

echo "# The output should be something like this:"
echo "#include <...> search starts here:"
echo " /usr/include"
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

# Убедимся, что новый компоновщик использует правильные пути для поиска
echo "--------"
echo "Step: 6"
echo "--------"
echo "verify that the new linker is being used with the correct search paths"
printf "grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\\\n|g'\n"

grep 'SEARCH.*/usr/lib' dummy.log | sed 's|; |\n|g'
echo ""

# ссылки на пути, в которых есть компоненты с -linux-gnu, должны
# игнорироваться, весь остальной вывод должен быть
echo -n "# The output should be something like this "
echo "(ignore components from /tools):"
echo 'SEARCH_DIR("/usr/lib")'
echo 'SEARCH_DIR("/lib")'
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

# убедимся, что мы используем правильный libc
echo "--------"
echo "Step: 7"
echo "--------"
echo "# make sure that we're using the correct libc"
echo 'grep "/lib.*/libc.so.6 " dummy.log'

grep "/lib.*/libc.so.6 " dummy.log
echo ""

echo "# The output should be something like this:"
echo "attempt to open /lib/libc.so.6 succeeded"
echo ""
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""

# наконец, убедимся, что GCC использует правильный динамический компоновщик
echo "--------"
echo "Step: 8"
echo "--------"
echo "# make sure GCC is using the correct dynamic linker"
echo "grep found dummy.log"

grep found dummy.log
echo ""

echo "# The output should be something like this:"
echo "found ld-linux-x86-64.so.2 at /lib/ld-linux-x86-64.so.2"
echo ""
echo ""

# если выходные данные не отображаются, как показано выше, или не получены
# вообще, значит, что-то серьезно не так. Любые проблемы должны быть решены,
# прежде чем продолжить процесс сборки.

# очищаем тестовые файлы:
echo "Cleaning:"
rm -v dummy.c a.out dummy.log
