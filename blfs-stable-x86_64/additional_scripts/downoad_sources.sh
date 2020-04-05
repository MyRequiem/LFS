#! /bin/bash

LFS="/mnt/lfs"
PART="/dev/sda10"
SOURCES="${LFS}/sources"
WGET_LIST="$(pwd)/wget-list"
LRED="\033[1;31m"
RESET="\033[0m"
ERRORS=""

if ! mount | /bin/grep -q "${LFS}"; then
    echo "Directory for building ${LFS} not mounted. You need to mount it:"
    echo "# mount ${PART} ${LFS}"
    exit 1
fi

cd "${SOURCES}" || exit 1

{
    while read -r URL; do
        wget --progress=bar:force -ct 0 -w 2 "${URL}" || \
            ERRORS="${ERRORS}\n${URL}"
    done
} < "${WGET_LIST}"

if [ -n "${ERRORS}" ]; then
    echo -en "\n${LRED}Warning!!!\nWhile the script was running, "
    echo -n "files download errors occurred. "
    echo -e "The following files have not been downloaded:${RESET}"
    echo -e "${ERRORS}"
fi
