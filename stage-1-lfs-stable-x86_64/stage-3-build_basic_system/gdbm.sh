#! /bin/bash

PRGNAME="gdbm"

### GDBM (GNU database routines)
# Библиотека для работы с простыми базами данных, которая позволяет программам
# быстро сохранять и находить нужную информацию в виде ключ-значение.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# ключ позволяет создать библиотеку совместимости, содержащую старые функции
# DBM (libgdbm_compat.so), так как некоторые пакеты за пределами LFS могут
# требовать этих более старых процедур
#    --enable-libgdbm-compat
./configure          \
    --prefix=/usr    \
    --disable-static \
    --enable-libgdbm-compat || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNU database routines)
#
# The GDBM package contains the GNU Database Manager. It is a library of
# database functions that use extensible hashing and work similar to the
# standard UNIX dbm. The library provides primitives for storing key/data
# pairs, searching and retrieving the data by its key and deleting a key along
# with its data.
#
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
