#! /bin/bash

PRGNAME="make"

### Make (GNU make utility to maintain groups of programs)
# Программы для компиляции

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/make.html

# Home page: http://www.gnu.org/software/make/
# Download:  http://ftp.gnu.org/gnu/make/make-4.3.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# набор тестов должен знать, где находятся служебные файлы Perl в дереве
# исходников. Для этого мы используем переменную окружения PERL5LIB
make PERL5LIB="${PWD}/tests/" check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU make utility to maintain groups of programs)
#
# This is the GNU implementation of make. The purpose of the make utility is to
# determine automatically which pieces of a large program need to be
# recompiled, and issue the commands to recompile them. This is needed to
# compile just about any major C program, including the Linux kernel.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
