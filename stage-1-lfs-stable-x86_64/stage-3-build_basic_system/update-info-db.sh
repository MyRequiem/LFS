#! /bin/bash

# обновляем базу данных info (/usr/share/info/dir)
INFO="/usr/share/info"
if [ -d "${TMP_DIR}${INFO}" ]; then
    cd "${TMP_DIR}${INFO}" || exit 1
    # оставляем только *info* файлы
    find . -type f ! -name "*info*" -delete
    for FILE in *; do
        install-info --dir-file="${INFO}/dir" "${FILE}" 2>/dev/null
    done
    cd - || exit 1
fi
