#! /bin/bash

PRGNAME="gcc"

### GCC (Base GCC package with C support)
# Набор компиляторов GNU, который превращает исходный код на C, C++ и других
# языках в готовые к работе программы. В системе LFS пакет будет включать
# только компиляторы C и C++. В BLFS будет добавлен набор компиляторов для ряда
# других языков: fortran, go, objc, obj-c++, m2

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{usr/lib/bfd-plugins,usr/share/gdb/auto-load/usr/lib}

# Изменим каталог для установки библиотек с lib64 на lib
sed -e '/m64=/s/lib64/lib/' -i.orig "${PRGNAME}/config/i386/t-linux64" || exit 1

# Документация gcc рекомендует собирать gcc в отдельном каталоге.
mkdir build
cd build || exit 1

# Включаем поддержку только С и C++
#    --enable-languages=c,c++
# Сообщим GCC, что нужно ссылаться на установленную в системе библиотеку Zlib,
# а не на собственную внутреннюю копию.
#    --with-system-zlib
../configure                 \
    --prefix=/usr            \
    LD=ld                    \
    --enable-languages=c,c++ \
    --enable-default-pie     \
    --enable-default-ssp     \
    --enable-host-pie        \
    --enable-targets=all     \
    --disable-multilib       \
    --disable-bootstrap      \
    --disable-fixincludes    \
    --with-system-zlib || exit 1

make || make -j1 || exit 1

###
# Набор тестов для GCC на данном этапе считается критическим. Нельзя пропускать
# его ни при каких обстоятельствах.
###
#
# Известно, что один набор тестов в наборе тестов GCC переполняет стек, поэтому
# размер стека установим бесконечный.
# ulimit -s -H unlimited
#
# Тесты будем запускать как непривилегированный пользователь tester, поэтому
# изменим владельца в директории сборки.
# chown -Rv tester .
# echo ""
# echo "# Now run GCC tests"
# echo 'su tester -c "PATH=$PATH make -k check"'
# echo -n "Press <Enter> for continue..."
# read -r JUNK
# echo "${JUNK}" > /dev/null
# su tester -c "PATH=$PATH make -k check"

# Пишем результаты тестов GCC в gcc-test.log
# ../contrib/test_summary -t 2>&1 | grep -A7 Summ > "${PRGNAME}-test.log"

# Вернем владельца сборочной директории обратно.
# chown -Rv root:root .

# Установим пакет.
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# Создадим ссылку в /usr/lib/, требуемую FHS по "историческим" причинам.
#    cpp -> ../bin/cpp
ln -svf ../bin/cpp "${TMP_DIR}/usr/lib"

# Многие программы используют имя 'cc' для вызова C-компилятора, поэтому
# создадим символическую ссылку в /usr/bin/
#    cc -> gcc
ln -svf gcc "${TMP_DIR}/usr/bin/cc"

ln -svf gcc.1 "${TMP_DIR}/usr/share/man/man1/cc.1"

# Добавим ссылку в  /usr/lib/bfd-plugins/ для совместимости, чтобы включить
# сборку программ с оптимизацией компоновки LTO (Link Time Optimization).
#    liblto_plugin.so -> \
#    ../../libexec/gcc/x86_64-pc-linux-gnu/${VERSION}/liblto_plugin.so
DUMPMACHINE="$("${TMP_DIR}/usr/bin/${PRGNAME}" -dumpmachine)"
ln -sfv "../../libexec/${PRGNAME}/${DUMPMACHINE}/${VERSION}/liblto_plugin.so" \
    "${TMP_DIR}/usr/lib/bfd-plugins/"

# Переместим некоторые файлы.
mv -v "${TMP_DIR}/usr/lib"/*gdb.py "${TMP_DIR}/usr/share/gdb/auto-load/usr/lib/"

# Если мы устанавливаем пакет в первый раз, удалим директории и файлы, которые
# были установлены GCC, построенным во временной системе.
if [ -d /usr/x86_64-lfs-linux-gnu ]; then
    rm -f  /usr/bin/x86_64-lfs-linux-gnu-*
    rm -rf "/usr/include/c++/${VERSION}/x86_64-lfs-linux-gnu"
    rm -rf /usr/lib/gcc/x86_64-lfs-linux-gnu
    rm -rf /usr/libexec/gcc/x86_64-lfs-linux-gnu
    rm -rf /usr/x86_64-lfs-linux-gnu
    rm -f  /usr/lib/libstdc++.so.6.0.33-gdb.py
fi

source "${ROOT}stripping.sh"      || exit 1
source "${ROOT}update-info-db.sh" || exit 1
source "${ROOT}clean-locales.sh"  || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

chmod 755 /usr/lib/libgcc_s.so{,.1}

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Base GCC package with C support)
#
# The GCC package contains the GNU compiler collection, which includes the C
# and C++ compilers.
#
# Home page: https://${PRGNAME}.gnu.org/
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
