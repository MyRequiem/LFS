#! /bin/bash

PRGNAME="diffutils"

### Diffutils
# Утилиты, которые показывают различия между файлами или каталогами

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/diffutils.html

# Home page: http://www.gnu.org/software/diffutils/
# Download:  http://ftp.gnu.org/gnu/diffutils/diffutils-3.7.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

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
# Package: ${PRGNAME} (finds differences between files)
#
# The GNU diff utilities finds differences between files. A major use
# diffutils: for this package is to make source code patches.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
