#! /bin/bash

PRGNAME="sqlite"
ARCH_NAME="${PRGNAME}-autoconf"

### SQLite (simple, self contained database engine)
# Пакет SQLite представляет собой программную библиотеку, которая реализует
# автономный, безсерверный, с нулевой конфигурацией механизм транзакционной
# базы данных SQL

# http://www.linuxfromscratch.org/blfs/view/stable/server/sqlite.html

# Home page: https://sqlite.org
# Download:  https://sqlite.org/2020/sqlite-autoconf-3310100.tar.gz
#            https://sqlite.org/2020/sqlite-doc-3310100.zip

# Required: unzip (для распаковки архива с документацией)
# Optional: libedit (https://www.thrysoee.dk/editline)

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

PRG_VERSION="$(grep "#define SQLITE_VERSION " sqlite3.c | cut -d \" -f 2)"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${PRG_VERSION}"
mkdir -pv "${TMP_DIR}"

# распакуем документацию
unzip "${SOURCES}/${PRGNAME}-doc-${VERSION}.zip"

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
DOCS="/usr/share/doc/${PRGNAME}-${PRG_VERSION}"
install -v -m755 -d "${DOCS}"
install -v -m755 -d "${TMP_DIR}${DOCS}"
cp -vR "sqlite-doc-${VERSION}"/* "${DOCS}"
cp -vR "sqlite-doc-${VERSION}"/* "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${PRG_VERSION}"
# Package: ${PRGNAME} (simple, self contained database engine)
#
# SQLite is a small C library that implements a self-contained, embeddable,
# zero-configuration SQL database engine. The SQLite distribution comes with a
# standalone command-line access program (sqlite) that can be used to
# administer an SQLite database and which serves as an example of how to use
# the SQLite library.
#
# Home page: https://sqlite.org
# Download:  https://sqlite.org/2020/${ARCH_NAME}-${VERSION}.tar.gz
#            https://sqlite.org/2020/${PRGNAME}-doc-${VERSION}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${PRG_VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
