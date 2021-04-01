#! /bin/bash

PRGNAME="berkeley-db"
ARCH_NAME="db"

### Berkeley DB (high-performance embedded database for key/value data)
# Высокопроизводительная встраиваемая система управления базами данных,
# реализованная в виде библиотеки. BDB является нереляционной базой данных -
# она хранит пары "ключ-значение" как массивы байтов и поддерживает множество
# значений для одного ключа. BDB может обслуживать тысячи процессов или
# потоков, одновременно манипулирующих базами данных размером в 256 терабайт,
# на разнообразном оборудовании под различными операционными системами, включая
# большинство UNIX-подобных систем и Windows, а также на операционных системах
# реального времени.

# Required:    no
# Recommended: no
# Optional:    sharutils (для утилиты uudecode)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# применим патч для успешной сборки с текущим g++
sed -i 's/\(__atomic_compare_exchange\)/\1_db/' src/dbinc/atomic.h || exit 1

cd build_unix || exit 1

# создавать совместимости API с DB-1.85
#    --enable-compat185
# включаем поддержку устаревшего интерфейса, необходимую для некоторых старых
# пакетов
#    --enable-dbm
# создавать API библиотеки C++
#    --enable-cxx
# включаем поддержку Tcl и создание библиотеки libdb_tcl
#    --enable-tcl
#    --with-tcl=/usr/lib
../dist/configure      \
    --prefix=/usr      \
    --enable-compat185 \
    --enable-dbm       \
    --disable-static   \
    --enable-cxx       \
    --enable-tcl       \
    --with-tcl=/usr/lib || exit 1

make || exit 1
make docdir="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc/"

chown -vR root:root "${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (high-performance embedded database for key/value data)
#
# Berkeley DB (BDB) is a software library intended to provide a
# high-performance embedded database for key/value data. This package contains
# programs and utilities used by many other applications for database related
# functions. Berkeley DB is written in C with API bindings for C++, C#, Java,
# Perl, PHP, Python, Ruby, Smalltalk, Tcl, and many other programming
# languages. BDB stores arbitrary key/data pairs as byte arrays, and supports
# multiple data items for a single key. Berkeley DB is not a relational
# database.
#
# Home page: https://www.oracle.com/database/technologies/related/berkeleydb.html
# Download:  http://anduin.linuxfromscratch.org/BLFS/bdb/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
