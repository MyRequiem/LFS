#! /bin/bash

PRGNAME="gcc"

### GCC (GNU compiler collection)
# Коллекция компиляторов для C, C++, D, Fortran, Go, Objective-C и
# Objective-C++ кода

# http://www.linuxfromscratch.org/blfs/view/stable/general/gcc.html

# Home page: https://gcc.gnu.org/
# Download:  https://ftp.gnu.org/gnu/gcc/gcc-10.2.0/gcc-10.2.0.tar.xz

# Required:    no
# Recommended: dejagnu  (для тестов)
# Optional:    gdb
#              valgrind (для тестов)
#              isl      (для включения оптимизации graphite) https://repo.or.cz/isl.git

### NOTE
# Для сборки версии 10.2.0 требуется минимум 12G свободного места + 1.1G для
# тестов
###

### NOTE
# Если в системе присутствуют сторонние модули ядра (например, nvidia.ko и
# т.д.) и мы обновляем GCC с более ранней версии, то после обновления GCC нужно
# будет пересобрать ядро, его собственные модули и потом все сторонние модули.
###

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
GDB="/usr/share/gdb/auto-load/usr/lib"
mkdir -pv "${TMP_DIR}"{"${GDB}",/lib,/usr/lib/bfd-plugins}

# установим имя каталога для 64-битных библиотек по умолчанию как 'lib'
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

mkdir build
cd build || exit 1

# сообщим GCC, что нужно ссылаться на установленную в системе библиотеку Zlib,
# а не на собственную внутреннюю копию
#    --with-system-zlib
# преднамеренно выполняем bootstrap (начальную загрузку) посколько это
# необходимо для надежности и настоятельно рекомендуется при обновлении версии
# компилятора
#    --enable-bootstrap
../configure           \
    --prefix=/usr      \
    --disable-multilib \
    --with-system-zlib \
    --enable-bootstrap \
    --enable-languages=c,c++,d,fortran,go,objc,obj-c++ || exit 1

# собираем в количество потоков равных количествую ядер
NUMJOBS="$(nproc)"
make -j"${NUMJOBS}" || exit 1

###
# Важно !!!
###
# Набор тестов для GCC на данном этапе считается критическим. Нельзя пропускать
# его ни при каких обстоятельствах. Если установлены опциональные пакеты gdb и
# valgrind, то будет запущено больше тестов, часть из которых будут терпеть
# неудачу и сообщать FAIL. Начиная с gcc-9.2.0 в среде LFS тестирование выдает
# не менее 120 ошибок.

# # известно, что один набор тестов в наборе тестов GCC переполняет стек, поэтому
# # увеличим размер стека
# ulimit -s 32768

# # запускаем тесты
# make -k check
# # пишем результаты тестов в gcc-test.log
# ../contrib/test_summary 2>&1 | grep -A7 Summ > gcc-test.log

make install
make install DESTDIR="${TMP_DIR}"

# переместим некоторые файлы
mkdir -pv "${GDB}"
mv -v /usr/lib/*gdb.py "${GDB}"
mv -v "${TMP_DIR}/usr/lib"/*gdb.py "${TMP_DIR}${GDB}"

LIB_GCC="/usr/lib/gcc/$(gcc -dumpmachine)/${VERSION}"
chown -vR root:root "${LIB_GCC}/include"{,-fixed}
chown -vR root:root "${TMP_DIR}${LIB_GCC}/include"{,-fixed}

# удалим ненужную директорию
# /usr/lib/gcc/x86_64-pc-linux-gnu/${VERSION}/include-fixed/bits
rm -rf "${LIB_GCC}/include-fixed/bits/"
rm -rf "${TMP_DIR}${LIB_GCC}/include-fixed/bits/"

# многие программы используют имя 'cc' для вызова компилятора C, поэтому
# создадим символическую ссылку cc -> gcc в /usr/bin/
ln -svf gcc /usr/bin/cc
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sv gcc cc
)

# создадим символическую ссылку в /lib/
# cpp -> ../usr/bin/cpp
# требуемую FHS по историческим причинам
ln -svf ../usr/bin/cpp /lib
(
    cd "${TMP_DIR}/lib" || exit 1
    ln -sv ../usr/bin/cpp cpp
)

# добавим символическую ссылку в /usr/lib/bfd-plugins/
# liblto_plugin.so ->
#    ../../libexec/gcc/x86_64-pc-linux-gnu/${VERSION}/liblto_plugin.so
# для совместимости, чтобы разрешить сборку программ с помощью
# Link Time Optimization (LTO)
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv "../../libexec/gcc/$(gcc -dumpmachine)/${VERSION}/liblto_plugin.so" \
        /usr/lib/bfd-plugins/

install -v -dm755 "${TMP_DIR}/usr/lib/bfd-plugins"
(
    cd "${TMP_DIR}/usr/lib/bfd-plugins" || exit 1
    ln -sfv \
        "../../libexec/gcc/$(gcc -dumpmachine)/${VERSION}/liblto_plugin.so" \
        liblto_plugin.so
)

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU compiler collection)
#
# The GCC package contains the GNU compiler collection, which includes the C,
# C++, D, Fortran, Go, Objective-C and Objective-C++ compilers
#
# Home page: https://${PRGNAME}.gnu.org/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

# После установки необходимо убедиться, что основные функции (компиляция и
# компоновка) работают должным образом. Вывод сообщений всех последующих команд
# должен быть на английском языке
LC_MESSAGES=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LANG=en_US.UTF-8
export LANG LC_CTYPE LC_MESSAGES

# для проверки работоспособности создадим простейший фиктивный C-файл и
# скомпилируем его собранным нами gcc для генерации объектного файла a.out:
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
echo "# compiling source file dummy.c using /usr/bin/cc (link to /usr/bin/gcc)"
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
echo "/usr/lib/gcc/x86_64-pc-linux-gnu/${VERSION}/../../../../lib/crt1.o succeeded"
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

# убедимся, что компилятор ищет правильные заголовочные файлы
echo "--------"
echo "Step: 5"
echo "--------"
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

# убедимся, что новый компоновщик использует правильные пути для поиска
echo "--------"
echo "Step: 6"
echo "--------"
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
echo -n "Press any key... "
read -r JUNK
echo "${JUNK}" > /dev/null
echo ""
# если выходные данные не отображаются, как показано выше, или не получены
# вообще, значит, что-то серьезно не так. Любые проблемы должны быть решены,
# прежде чем продолжить процесс сборки.

# очистим созданные нами тестовые файлы
echo "Cleaning:"
rm -v dummy.c a.out dummy.log

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
