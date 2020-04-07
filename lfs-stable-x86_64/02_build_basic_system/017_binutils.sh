#! /bin/bash

PRGNAME="binutils"

### Binutils
# Пакет содержит компоновщик, ассемблер и другие инструменты для работы с
# объектными файлами

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/binutils.html

# Home page: http://www.gnu.org/software/binutils/
# Download:  http://ftp.gnu.org/gnu/binutils/binutils-2.34.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# убедимся, что PTY работают правильно в среде chroot выполнив простой тест
echo ""
echo "# Checking PTY settings..."
echo 'expect -c "spawn ls"'
expect -c "spawn ls"
echo -ne "\nYou see the message \"spawn ls\" above [y/N]? "
read -r JUNK
[[ "x${JUNK}" != "xy" && "x${JUNK}" != "xY" ]] && exit 1
# Если вместо "spawn ls" вывод примерно такой:
#    The system has no more ptys.
#    Ask your system administrator to create more.
# то среда настроена НЕ правильно для работы PTY. Эту проблему необходимо
# решить перед запуском тестовых пакетов для Binutils и GCC

# удалим один тест tincremental_copy, который препятствует выполнению тестов до
# самого конца
sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in || exit 1

# документация Binutils рекомендует собирать binutils в отдельном каталоге для
# сборки
mkdir build
cd build || exit 1

### Конфигурация
# создать "gold linker" и установить его как ld.gold рядом с компоновщиком по
# умолчанию
#    --enable-gold
# создать оригинальный компоновщик bdf и установить его как ld (компоновщик по
# умолчанию) и ld.bfd
#    --enable-ld=default
# включаем поддержку плагинов для компоновщика
#    --enable-plugins
# включаем 64-битную поддержку. Может не понадобиться на 64-битных системах, но
# не повредит
# --enable-64-bit-bfd
# использовать уже установленную библиотеку zlib, а не собирать встроенную
# версию
#    --with-system-zlib
../configure            \
    --prefix=/usr       \
    --enable-gold       \
    --enable-ld=default \
    --enable-plugins    \
    --enable-shared     \
    --disable-werror    \
    --enable-64-bit-bfd \
    --with-system-zlib || exit 1

# обычно tooldir, т.е. каталог, где в конечном итоге будут находиться
# исполняемые файлы, устанавливается в $(exec_prefix)/$(target_alias)
# Машины с архитектурой x86_64 будут расширять этот путь до
# /usr/x86_64-unknown-linux-gnu, но каталог x86_64-unknown-linux-gnu в /usr нам
# не требуется, поэтому явно указываем tooldir
make tooldir=/usr || exit 1

###
# Важно !!!
###
# Набор тестов для Binutils на данном этапе считается критическим. Нельзя
# пропускать его ни при каких обстоятельствах
make -k check
# тесты PC-relative offset и debug_msg.sh могут не пройти в среде LFS

# устанавливаем пакет
make tooldir=/usr install
make tooldir=/usr install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU binary development tools)
#
# Binutils is a collection of binary utilities. It includes "as" (the portable
# GNU assembler), "ld" (the GNU linker), and other utilities for creating and
# working with binary programs. These utilities are REQUIRED to compile C, C++,
# Objective-C, Fortran, and most other programming languages.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
