#! /bin/bash

PRGNAME="m4"

### M4
# Пакет M4 содержит макропроцессор

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/m4.html

# Home page: http://www.gnu.org/software/m4/
# Download:  http://ftp.gnu.org/gnu/m4/m4-1.4.18.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# внесем исправления, необходимые для glibc-2.28
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

./configure \
    --prefix=/usr || exit 1

make || exit 1
make check
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

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

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
