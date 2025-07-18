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

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
