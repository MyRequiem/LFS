#! /bin/bash

# Удаляем отладочную информацию (debug symbols) из двоичных файлов и библиотек.
# Также удаляем все записи таблицы символов, не требуемые линкером (для
# статических библиотек) или динамическим линкером (для динамически связанных
# двоичных файлов и общих библиотек)

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

BINARY="$(find /usr/bin /usr/lib /usr/libexec /usr/sbin \
    -type f -print0 | xargs -0 file 2>/dev/null | \
    /bin/grep -e "executable" -e "shared object" | /bin/grep "ELF" | \
    /bin/grep -e "with debug_info" -e "not stripped" | \
    /bin/grep -v "32-bit" | cut -f 1 -d :)"

for BIN in ${BINARY}; do
    DESTDIR="$(dirname "${BIN}")"
    BIN_NAME="$(basename "${BIN}")"

    cp "${BIN}" /tmp/
    strip --strip-unneeded "/tmp/${BIN_NAME}"
    install -vm755 "/tmp/${BIN_NAME}" "${DESTDIR}/"
    rm -f "/tmp/${BIN_NAME}"
done
