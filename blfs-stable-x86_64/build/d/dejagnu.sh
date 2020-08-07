#! /bin/bash

PRGNAME="dejagnu"

### DejaGnu (program tester)
# Фреймворк для тестирования других программ, предоставляющий единый интерфейс
# для всех тестов. Так же можно рассматривать как пользовательскую библиотеку
# процедур Tcl, созданную для поддержки написания программных тестов. DejaGnu
# написан на Expect, который  использует командный язык Tcl

# http://www.linuxfromscratch.org/blfs/view/stable/general/dejagnu.html

# Home page: http://www.gnu.org/software/dejagnu/
# Download:  https://ftp.gnu.org/gnu/dejagnu/dejagnu-1.6.2.tar.gz

# Required: expect
# Optional: docbook-utils
#           docbook2x     (http://docbook2x.sourceforge.net/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

./configure \
    --prefix=/usr || exit 1

makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi || exit 1
makeinfo --plaintext       -o doc/dejagnu.txt  doc/dejagnu.texi || exit 1

# make check

make install
make install DESTDIR="${TMP_DIR}"

install -v -dm755 "${DOCS}"
install -v -m644 doc/dejagnu.{html,txt} "${DOCS}"
install -v -m644 doc/dejagnu.{html,txt} "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (program tester)
#
# DejaGnu is a framework for testing other programs. Its purpose is to provide
# a single front end for all tests. Think of it as a custom library of Tcl
# procedures crafted to support writing a test harness. A test harness is the
# testing infrastructure that is created to support a specific program or tool.
# Each program can have multiple testsuites, all supported by a single test
# harness. DejaGnu is written in Expect, which in turn uses Tcl -- Tool command
# language.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
