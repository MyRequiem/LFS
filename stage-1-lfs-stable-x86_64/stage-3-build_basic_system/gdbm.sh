#! /bin/bash

PRGNAME="gdbm"

### GDBM (GNU database routines)
# Пакет содержит менеджер баз данных GNU. Это библиотека функций баз данных,
# которые используют расширяемое хеширование и работают аналогично стандартному
# dbm в UNIX. Библиотека предоставляет примитивы для хранения пар
# ключ-значение, поиска и извлечение данных по ключу и удаление ключа вместе с
# его данными.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# устраним проблему, обнаруженную при сборке с gcc-10
sed -r -i '/^char.*parseopt_program_(doc|args)/d' src/parseopt.c

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
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
