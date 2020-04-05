#! /bin/bash

PRGNAME="gawk"

### Gawk
# Программы для работы с текстовыми файлами

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/gawk.html

# Home page: http://www.gnu.org/software/gawk/
# Download:  http://ftp.gnu.org/gnu/gawk/gawk-5.0.1.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# не будем устанавливать некоторые ненужные файлы из группы extras
sed -i 's/extras//' Makefile.in

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}${DOCDIR}"
make install DESTDIR="${TMP_DIR}"

# установим документацию
mkdir -v "${DOCDIR}"
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} "${DOCDIR}"
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} "${TMP_DIR}${DOCDIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (pattern scanning and processing language)
#
# Gawk package contains programs for manipulating text files. Gawk is the GNU
# Project's implementation of the AWK programming language. This version in
# turn is based on the description in The AWK Programming Language with the
# additional features found in the System V Release 4 version of UNIX awk. Gawk
# also provides more recent Bell Labs awk extensions, and some GNU-specific
# extensions.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
