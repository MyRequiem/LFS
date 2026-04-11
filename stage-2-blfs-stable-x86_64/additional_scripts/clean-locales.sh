#! /bin/bash

LOCALEDIR="/usr/share/locale"

# оставляем только нужные локали
KEEP_LOCALES="ru ru_RU ru_RU.UTF-8 en en_US en_US.UTF-8 en_GB en_GB.UTF-8"

if [ -d "${TMP_DIR}${LOCALEDIR}" ]; then
    # формируем аргументы для find: ! -name 'ru' ! -name 'en' ...
    FIND_ARGS=""
    for LOC in ${KEEP_LOCALES}; do
        FIND_ARGS="${FIND_ARGS} ! -name ${LOC}"
    done

    # удаляем всё, что не входит в список (только директории 1-го уровня)
    # shellcheck disable=SC2086
    find "${TMP_DIR}${LOCALEDIR}" -mindepth 1 -maxdepth 1 \
        -type d ${FIND_ARGS} -exec rm -rf {} +
fi
