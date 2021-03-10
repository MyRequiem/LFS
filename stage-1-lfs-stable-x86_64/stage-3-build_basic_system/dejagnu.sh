#! /bin/bash

PRGNAME="dejagnu"

### DejaGnu (program tester)
# Фреймворк для тестирования других программ, предоставляющий единый интерфейс
# для всех тестов. Так же можно рассматривать как пользовательскую библиотеку
# процедур Tcl, созданную для поддержки написания программных тестов. DejaGnu
# написан на Expect, который  использует командный язык Tcl

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make install DESTDIR="${TMP_DIR}"

# тесты
# make check

rm -f "${TMP_DIR}/usr/share/info/dir"

/bin/cp -vR "${TMP_DIR}"/* /

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
