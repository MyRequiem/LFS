#! /bin/bash

PRGNAME="automake"

### Automake (a Makefile generator)
# Пакет содержит программы создания Make-файлов для использования с Autoconf

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим тест
sed -i "s/''/etags/" t/tags-lisp-space.sh

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1

# здесь можно запускать тесты в несколько потоков (это ускорит тестирование
# даже в системах с одним процессором, из-за внутренних задержек в отдельных
# тестах)
# известно, что тест t/subobj.sh не проходит в среде LFS
# make -j4 check

make install DESTDIR="${TMP_DIR}"

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
# Package: ${PRGNAME} (a Makefile generator)
#
# This is Automake, a Makefile generator which contains programs for producing
# shell scripts that can automatically configure source code. It was inspired
# by the 4.4BSD make and include files, but aims to be portable and to conform
# to the GNU standards for Makefile variables and targets. Automake is a Perl
# script. The input files are called Makefile.am. The output files are called
# Makefile.in; they are intended for use with Autoconf. Automake requires
# certain things to be done in your configure.in. You must install the "m4" and
# "perl" packages to be able to use automake.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
