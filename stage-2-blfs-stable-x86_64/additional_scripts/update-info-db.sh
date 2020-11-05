#! /bin/bash

# обновляем базу данных info (/usr/share/info/dir)
INFO="/usr/share/info"
if [ -d "${TMP_DIR}${INFO}" ]; then
    cd "${TMP_DIR}${INFO}" || exit 1
    rm -f dir
    for FILE in *; do
        install-info --dir-file=/usr/share/info/dir "${FILE}" 2>/dev/null
    done
fi
