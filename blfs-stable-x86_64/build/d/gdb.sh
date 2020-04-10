#! /bin/bash

PRGNAME="gdb"

### GNU symbolic debugger
# Отладчик проекта GNU, который работает на многих UNIX-подобных системах и
# умеет производить отладку многих языков программирования, включая Си, C++,
# Free Pascal, FreeBASIC, Ada, Фортран, Rust и др.

# http://www.linuxfromscratch.org/blfs/view/9.0/general/gdb.html

# Home page: http://www.gnu.org/software/gdb/
# Download:  https://ftp.gnu.org/gnu/gdb/gdb-8.3.tar.xz

# Required: six (required at run-time)
# Optional: dejagnu (для тестов)
#           doxygen (для сборки документации)
#           gcc-ada и gcc-gfortran (для тестов)
#           guile
#           python2
#           rustc (для тестов)
#           valgrind
#           systemtap (для тестов)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure                \
    --prefix=/usr          \
    --with-system-readline \
    --with-python=/usr/bin/python3 || exit 1

make || exit 1

# для создания API документации требуется пакет doxygen, который пока не
# установлен
# make -C gdb/doc doxy

### тесты
# pushd gdb/testsuite || exit 1
# make  site.exp
# echo  "set gdb_test_timeout 120" >> site.exp
# runtest
# popd || exit 1

make -C gdb install
make -C gdb install DESTDIR="${TMP_DIR}"

### если собирали API документацию:
# DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
# rm -rf gdb/doc/doxy/xml
# install -d "${DOCS}"
# install -d "${TMP_DIR}${DOCS}"
# cp -Rv gdb/doc/doxy "${DOCS}"
# cp -Rv gdb/doc/doxy "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (the GNU symbolic debugger)
#
# GDB, the GNU Project debugger, allows you to see what is going on inside
# another program while it executes -- or what another program was doing at the
# moment it crashed. GDB can do four main kinds of things to help you catch
# bugs in the act:
#     1) Start your program, specifying anything that might affect its behavior
#     2) Make your program stop on specified conditions
#     3) Examine what has happened, when your program has stopped
#     4) Change things in your program, so you can experiment with correcting
#         the effects of one bug and go on to learn about another.
# The program being debugged can be written in Ada, C, C++, Objective-C, Pascal
# and many other languages.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
