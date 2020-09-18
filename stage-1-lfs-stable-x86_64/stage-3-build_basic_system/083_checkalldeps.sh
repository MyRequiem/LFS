#! /bin/sh

# Checking the dependencies of all binary files in the system using the ldd
# utility.
# Created by MyRequiem <mrvladislavovich@gmail.com>

# install this script:
# --------------------
#    # cp 083_checkalldeps.sh /mnt/lfs/sbin/checkalldeps.sh
#    # chown root:root /mnt/lfs/sbin/checkalldeps.sh
#    # chmod 744 /mnt/lfs/sbin/checkalldeps.sh

### BLACKLIST example:
# BLACKLIST="\
#     /usr/bin/opera \
#     /opt/GuitarPro6/GuitarPro \
# "
#
BLACKLIST=""

export LC_MESSAGES=en_US.UTF-8

DIRS="\
    /bin \
    /sbin \
    /lib \
    /usr/bin \
    /usr/sbin \
    /usr/lib \
    /usr/local/bin \
    /usr/local/sbin \
    /usr/local/lib \
    /usr/libexec \
    /opt \
"

SCRIPTNAME=$(basename "$0")
LOG=/tmp/${SCRIPTNAME}.log
TMP=/tmp/${SCRIPTNAME}.tmp
ERRORS=/tmp/${SCRIPTNAME}.err
EXCLUDE="not a dynamic executable|not have execution permission"
/bin/false > "${LOG}"

for DIR in ${DIRS}; do
    if [ -d "${DIR}" ]; then
        echo -e "\033[0;33m${DIR}/\033[0m"
        find "${DIR}" -type f 2>/dev/null | while read -r FILE; do
            if ! file "${FILE}" | grep -e "shared object" -e "executable" | \
                    grep ELF 1>/dev/null 2>&1; then
                continue
            fi

            for BL in ${BLACKLIST}; do
                [[ "x${FILE}" == "x${BL}" ]] && continue 2
            done

            /bin/false > "${TMP}"
            /usr/bin/ldd "${FILE}" 2>"${ERRORS}" | \
                grep -E "not found|no version information" | \
                sort -u > "${TMP}"

            if grep -Eq "${EXCLUDE}" "${ERRORS}"; then
                /bin/false > "${ERRORS}"
            fi

            cat "${ERRORS}" >> "${TMP}"
            if [ "$(stat -c%s "${TMP}")" != "0" ]; then
                    echo -e "\033[0;31m${FILE}\033[0;35m"
                    cat "${TMP}"
                    echo -e "\033[0m"
                    {
                        echo -e "${FILE}\n------------------"
                        cat "${TMP}"
                        echo
                    } >> "${LOG}"
            else
                echo "${FILE}"
            fi
        done
    fi
done

rm -f "${TMP}" "${ERRORS}"

if [ "$(stat -c%s "${LOG}")" != "0" ]; then
    echo -e "\n\033[0;31mldd found problems with dependencies"
    echo -e "\033[1;34mlog file: ${LOG}\033[0m\n"
else
    rm -f "${LOG}"
    echo -en "\n\033[1;32mCongratulations !!! ldd not found problems with "
    echo -e "dependencies\033[0m\n"
fi
