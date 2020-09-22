#! /bin/bash

PRGNAME="gcc"

### GCC (Base GCC package with C support)
# Пакет содержит компиляторы GNU для C и C++

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/gcc.html

# Home page: https://gcc.gnu.org/

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{lib,usr/lib/bfd-plugins,usr/share/gdb/auto-load/usr/lib}

# установим имя каталога для 64-битных библиотек по умолчанию как 'lib'
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64

# документация gcc рекомендует собирать gcc в отдельном каталоге
mkdir build
cd build || exit 1

# для других языков есть некоторые предварительные условия, которые пока не
# доступны в нашей системе. Смотри BLFS для получения инструкций по созданию
# всех поддерживаемых языков GCC:
# http://www.linuxfromscratch.org/blfs/view/stable/general/gcc.html
#    --enable-languages=c,c++
# сообщим GCC, что нужно ссылаться на установленную в системе библиотеку Zlib,
# а не на собственную внутреннюю копию
#    --with-system-zlib
../configure            \
    --prefix=/usr       \
    LD=ld               \
    --disable-multilib  \
    --disable-bootstrap \
    --with-system-zlib  \
    --enable-languages=c,c++ || exit 1

make || make -j1 || exit 1

#### Набор тестов для GCC на данном этапе считается критическим. Нельзя
# пропускать его ни при каких обстоятельствах
#
# известно, что один набор тестов в наборе тестов GCC переполняет стек, поэтому
# увеличим размер стека
# ulimit -s 32768
#
# тесты будем запускать как непривилегированный пользователь tester, поэтому
# изменим владельца в директории сборки
# chown -Rv tester .
# echo ""
# echo "# Now run GCC tests"
# echo 'su tester -c "PATH=$PATH make -k check"'
# echo -n "Press any key for continue..."
# read -r JUNK
# echo "${JUNK}" > /dev/null
# su tester -c "PATH=$PATH make -k check"

# пишем результаты тестов GCC в gcc-test.log. Известно, что шесть тестов,
# связанных с get_time не проходят (по-видимому, они связаны с локалью en_HK).
# Тесты asan_test.C, co-ret-17-void-ret-coro.C, pr95519-05-gro.C, pr80166.c так
# же не проходят с glibc-2.32
# ../contrib/test_summary 2>&1 | grep -A7 Summ > gcc-test.log

# вернем владельца сборочной директории обратно
# chown -Rv root:root .

# установим пакет
make install DESTDIR="${TMP_DIR}"

# удалим ненужную директорию
# /usr/lib/gcc/x86_64-pc-linux-gnu/${VERSION}/include-fixed/bits
rm -rf \
    "${TMP_DIR}/usr/lib/gcc/$(gcc -dumpmachine)/${VERSION}/include-fixed/bits/"

# создадим символическую ссылку в /lib/
# cpp -> ../usr/bin/cpp
# требуемую FHS по историческим причинам
(
    cd "${TMP_DIR}/lib" || exit 1
    ln -sv ../usr/bin/cpp cpp
)

# многие программы используют имя 'cc' для вызова C-компилятора, поэтому
# создадим символическую ссылку cc -> gcc в /usr/bin/
ln -sv gcc /usr/bin/cc
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sv gcc cc
)

# добавим символическую ссылку в /usr/lib/bfd-plugins/
# liblto_plugin.so ->
#    ../../libexec/gcc/x86_64-pc-linux-gnu/${VERSION}/liblto_plugin.so
# для совместимости, чтобы разрешить сборку программ с помощью LTO (Link Time
# Optimization)
DUMPMACHINE="$("${TMP_DIR}/usr/bin/gcc" -dumpmachine)"
(
    cd "${TMP_DIR}/usr/lib/bfd-plugins" || exit 1
    ln -sfv \
        "../../libexec/gcc/${DUMPMACHINE}/${VERSION}/liblto_plugin.so" \
        liblto_plugin.so
)

# переместим некоторые файлы
mv -v "${TMP_DIR}/usr/lib"/*gdb.py "${TMP_DIR}/usr/share/gdb/auto-load/usr/lib"

chmod 755 "${TMP_DIR}/usr/lib/libgcc_s.so"{,.1}

# удалим директории, которые были установлены в систему временным GCC
rm -rf "/usr/include/c++/${VERSION}/x86_64-lfs-linux-gnu"
rm -rf /usr/lib/gcc/x86_64-lfs-linux-gnu
rm -rf /usr/libexec/gcc/x86_64-lfs-linux-gnu

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Base GCC package with C support)
#
# The GCC package contains the GNU compiler collection, which includes the C
# and C++ compilers.
#
# Home page: https://gcc.gnu.org/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
