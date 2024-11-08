#! /bin/bash

PRGNAME="binutils"

### Binutils (GNU binary development tools)
# Пакет содержит компоновщик, ассемблер и другие инструменты для работы с
# объектными файлами

###
# NOTE:
###
# При обновлении binutils на другую версию, пакет пересобираем и устанавливаем
# дважды, и только потом удаляем библиотеки передыдущей версии

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# документация Binutils рекомендует собирать binutils в отдельном каталоге
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
#    --enable-64-bit-bfd
# использовать уже установленную библиотеку zlib, а не собирать встроенную
# версию
#    --with-system-zlib
../configure            \
    --prefix=/usr       \
    --sysconfdir=/etc   \
    --enable-gold       \
    --enable-ld=default \
    --enable-plugins    \
    --enable-shared     \
    --disable-werror    \
    --enable-64-bit-bfd \
    --enable-new-dtags  \
    --with-system-zlib  \
    --enable-default-hash-style=gnu || exit 1

# обычно tooldir, т.е. каталог, где в конечном итоге будут находиться
# исполняемые файлы, устанавливается в $(exec_prefix)/$(target_alias)
# Машины с архитектурой x86_64 будут расширять этот путь до
# /usr/x86_64-unknown-linux-gnu, но каталог x86_64-unknown-linux-gnu в /usr нам
# не требуется, поэтому явно указываем tooldir
make tooldir=/usr || make -j1 tooldir=/usr || exit 1

###
# Важно !!!
###
# Набор тестов для Binutils на данном этапе считается критическим. Нельзя
# пропускать его ни при каких обстоятельствах
# make -k check
# получить список неудачных тестов:
#    # grep '^FAIL:' $(find -name '*.log')

make tooldir=/usr install DESTDIR="${TMP_DIR}"

# удалим бесполезные статические библиотеки
rm -fv "${TMP_DIR}/usr/lib"/lib{bfd,ctf,ctf-nobfd,gprofng,opcodes,sframe}.a

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
