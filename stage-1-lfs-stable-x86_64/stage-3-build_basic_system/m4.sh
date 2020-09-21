#! /bin/bash

PRGNAME="m4"

### M4 (an implementation of the UNIX macro processor)
# Макропроцессор. Копирует ввод на вывод, используя макросы. Макросы могут быть
# как встроеными, так и пользовательскими и могут иметь несколько аргументов.
# Помимо макро-преобразований, m4 имеет встроеные функции для включения
# именованых файлов, запуска команд Unix, целочисленной арифметики,
# разносторонними манипуляциями с текстом, рекурсию и др. M4 может
# использоваться в качестве front-end для компиляторов или как макропроцессор
# на усмотрение пользователя.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/m4.html

# Home page: http://www.gnu.org/software/m4/

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# внесем исправления, необходимые для glibc-2.28
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c || exit 1
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (an implementation of the UNIX macro processor)
#
# This is GNU m4, a program which copies its input to the output, expanding
# macros as it goes. m4 has built-in functions for including named files,
# running commands, doing integer arithmetic, manipulating text in various
# ways, recursion, etc... Macros can also be user- defined, and can take any
# number of arguments.
#
# Home page: http://www.gnu.org/software/m4/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
