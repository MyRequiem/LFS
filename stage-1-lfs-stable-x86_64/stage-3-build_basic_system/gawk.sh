#! /bin/bash

PRGNAME="gawk"

### Gawk (pattern scanning and processing language)
# Программы для работы с текстовыми файлами

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# не будем устанавливать некоторые ненужные файлы из группы extras
sed -i 's/extras//' Makefile.in

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
# make check
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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
