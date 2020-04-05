#! /bin/bash

PRGNAME="sqlite"
ARCH_NAME="sqlite-autoconf"

### SQLite
# Пакет SQLite представляет собой программную библиотеку, которая реализует
# автономный, безсерверный, с нулевой конфигурацией механизм транзакционной
# базы данных SQL

# http://www.linuxfromscratch.org/blfs/view/9.0/server/sqlite.html

# Home page: https://sqlite.org
# Download:  https://sqlite.org/2019/sqlite-autoconf-3290000.tar.gz
#            https://sqlite.org/2019/sqlite-doc-3290000.zip

# Required: unzip
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

VERSION="3.29.0"
TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# распакуем документацию
unzip -q /sources/sqlite-doc-3290000.zip

# включить 5 версию расширения полнотекстового поиска
#    --enable-fts5
./configure                           \
    --prefix=/usr                     \
    --disable-static                  \
    --enable-fts5                     \
    CFLAGS="-g -O2                    \
    -DSQLITE_ENABLE_FTS3=1            \
    -DSQLITE_ENABLE_FTS4=1            \
    -DSQLITE_ENABLE_COLUMN_METADATA=1 \
    -DSQLITE_ENABLE_UNLOCK_NOTIFY=1   \
    -DSQLITE_ENABLE_DBSTAT_VTAB=1     \
    -DSQLITE_SECURE_DELETE=1          \
    -DSQLITE_ENABLE_FTS3_TOKENIZER=1" || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

# установим документацию
install -v -m755 -d "/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -m755 -d "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
cp -v -R sqlite-doc-3290000/* "/usr/share/doc/${PRGNAME}-${VERSION}"
cp -v -R sqlite-doc-3290000/* "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (simple, self contained database engine)
#
# SQLite is a small C library that implements a self-contained, embeddable,
# zero-configuration SQL database engine. The SQLite distribution comes with a
# standalone command-line access program (sqlite) that can be used to
# administer an SQLite database and which serves as an example of how to use
# the SQLite library.
#
# Home page: https://sqlite.org
# Download:  https://sqlite.org/2019/${PRGNAME}-autoconf-3290000.tar.gz
#            https://sqlite.org/2019/${PRGNAME}-doc-3290000.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
