#! /bin/bash

config_file_processing() {
    CURR_CONFIG="$1"
    OLD_CONFIG="${CURR_CONFIG}.old"
    rm -vf "${CURR_CONFIG}.new"

    if [[ -f "${CURR_CONFIG}" && -f "${OLD_CONFIG}" ]]; then
        MD5_CURR="$(md5sum < "${CURR_CONFIG}")"
        MD5_OLD="$(md5sum < "${OLD_CONFIG}")"
        if [[ "${MD5_CURR}" == "${MD5_OLD}" ]]; then
            rm -vf "${OLD_CONFIG}"
        else
            mv -v "${CURR_CONFIG}" "${CURR_CONFIG}.new"
            mv -v "${OLD_CONFIG}"  "${CURR_CONFIG}"
        fi
    fi
}
