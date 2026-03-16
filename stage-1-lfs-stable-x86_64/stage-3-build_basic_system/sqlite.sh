#! /bin/bash

PRGNAME="sqlite"
ARCH_NAME="sqlite-autoconf"

### SQLite (simple, self contained database engine)
# Компактная и быстрая база данных, которая хранит всю информацию в одном
# обычном файле. Не требует сложной настройки и используется программами для
# удобного хранения настроек, истории или списков.

ROOT="/"
source "${ROOT}check_environment.sh"                    || exit 1
source "${ROOT}unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

PRG_VERSION="$(grep "#define SQLITE_VERSION " sqlite3.c | cut -d \" -f 2)"
if [ -z "${PRG_VERSION}" ]; then
    echo "Can't determine package version in sqlite3.c"
    exit 1
fi

TMP_DIR="/tmp/pkg-${PRGNAME}-${PRG_VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# включаем поддержку версий 4 и 5 расширения для полнотекстового поиска
# (full text search (FTS) extension)
#    --enable-fts{4,5}
# некоторые приложения требуют включения этих опций. Единственный способ
# сделать это - включить их в CFLAGS или CPPFLAGS. Мы используем последнее,
# поэтому значение по умолчанию (или любое значение, установленное
# пользователем) CFLAGS не будет затронуто
#    CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 ...
./configure           \
    --prefix=/usr     \
    --disable-static  \
    --enable-fts{4,5} \
    CPPFLAGS="-D SQLITE_ENABLE_COLUMN_METADATA=1 \
              -D SQLITE_ENABLE_UNLOCK_NOTIFY=1   \
              -D SQLITE_ENABLE_DBSTAT_VTAB=1     \
              -D SQLITE_SECURE_DELETE=1" || exit 1

# предотвращает жесткое кодирование путей поиска библиотеки (rpath) в общей
# библиотеке. Этому пакету не требуется rpath для установки в стандартное
# расположение, и rpath иногда может вызывать нежелательные эффекты или даже
# проблемы с безопасностью
#    LDFLAGS.rpath=""
make LDFLAGS.rpath="" || exit 1

# пакет не содержит набора тестов

make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${PRG_VERSION}"
# Package: ${PRGNAME} (simple, self contained database engine)
#
# SQLite is a small C library that implements a self-contained, embeddable,
# zero-configuration SQL database engine. The SQLite distribution comes with a
# standalone command-line access program (sqlite) that can be used to
# administer an SQLite database and which serves as an example of how to use
# the SQLite library.
#
# Home page: https://${PRGNAME}.org
# Download:  https://${PRGNAME}.org/2026/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${PRG_VERSION}"
