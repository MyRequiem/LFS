#! /bin/bash

VERSION="stable"
BOOK_URL="http://www.linuxfromscratch.org"
ERRATA_LFS_URL="${BOOK_URL}/lfs"
ERRATA_BLFS_URL="${BOOK_URL}/blfs"
LGREEN="\033[1;32m"
BROWN="\033[0;33m"
LRED="\033[1;31m"
GRAY="\033[0;37m"
LBLUE="\033[1;34m"
RESET="\033[0m"
MOVE_CURS_TO_40_COL="\033[40G"
PACKAGES="/var/log/packages"
mount | grep -q /mnt/lfs && PACKAGES="/mnt/lfs${PACKAGES}"
TMP="/tmp/lfs-errata.tmp"
TMP_SORT="/tmp/lfs-errata_sort.tmp"

show_packages() {
    echo -e "${LGREEN}$1${RESET}"

    BASE_URL="${ERRATA_LFS_URL}"
    [[ "$1" == "BLFS" ]] && BASE_URL="${ERRATA_BLFS_URL}"

    /bin/false > "${TMP}"
    for ITEM in $2; do
        if [[ $ITEM =~ http:// ]]; then
            PKG="$(echo "${ITEM}" | rev | cut -d / -f 1 | rev | \
                cut -d - -f 1,2)"
            URL="$(echo "${ITEM}" | cut -d \" -f 1)"
            # переводим всю строку в нижний регистр
            echo "${PKG} ${URL}" | tr '[:upper:]' '[:lower:]' >> "${TMP}"
        else
            PKG="$(echo "${ITEM}" | cut -d \> -f 2)"
            URL="${BASE_URL}/$(echo "${ITEM}" | cut -d / -f 3- | \
                cut -d \" -f 1)"
            # переводим всю строку в нижний регистр
            echo "${PKG} ${URL}" | tr '[:upper:]' '[:lower:]' >> "${TMP}"
        fi
    done

    sort "${TMP}" > "${TMP_SORT}"

    {
        while read -r LINE; do
            PKG="$(echo "${LINE}" | cut -d " " -f 1)"
            PKGNAME="$(echo "${PKG}" | rev | cut -d - -f 2- | rev)"
            VER="$(echo "${PKG}" | rev | cut -d - -f 1 | rev)"

            if [[ "${PKGNAME}" == "python" ]]; then
                PKGNAME="${PKGNAME}$(echo "${VER}" | cut -d . -f 1)"
            fi

            if [[ "${PKGNAME}" == "qt" ]]; then
                PKGNAME="${PKGNAME}$(echo "${VER}" | cut -d . -f 1)"
            fi

            if [[ "${PKGNAME}" == "webkitgtk+" ]]; then
                PKGNAME="${PKGNAME}$(echo "${VER}" | cut -d . -f 1)"
            fi

            if [[ "${PKGNAME}" == "node.js" ]]; then
                PKGNAME="nodejs"
            fi

            INSTALL_PKG="$(ls "${PACKAGES}/${PKGNAME}-"[0-9]* 2>/dev/null)"

            if [ -n "${INSTALL_PKG}" ] ; then
                INSTALL_VER="$(echo "${INSTALL_PKG}" | rev | \
                    cut -d - -f 1 | rev)"

                if [[ "${INSTALL_VER}" == "${VER}" ]]; then
                    COLOR="${BROWN}"
                else
                    COLOR="${LRED}"
                fi
            else
                COLOR="${GRAY}"
            fi

            URL="$(echo "${LINE}" | cut -d " " -f 2)"
            echo -en "${COLOR}${PKGNAME}-${VER}${MOVE_CURS_TO_40_COL}"
            echo -e  "${LBLUE}${URL}${RESET}"
        done
    } < "${TMP_SORT}"
}

get_pkg_list() {
    PKG_LIST_1="$(wget -q -O - "$1/errata/${VERSION}/" | \
        grep '<a href="../../view/' | grep -v "development version of the" | \
        cut -d \" -f 2- | cut -d \< -f 1)"
    PKG_LIST_2="$(wget -q -O - "$1/errata/${VERSION}/" | \
        grep '<a href="http://linuxfromscratch.org/patches/downloads/' | \
        grep -v "development version of the" | \
        cut -d \" -f 2- | cut -d \< -f 1)"
    PKG_LIST="${PKG_LIST_1} ${PKG_LIST_2}"
}

get_pkg_list "${ERRATA_LFS_URL}"
show_packages LFS "${PKG_LIST}"
echo ""
get_pkg_list "${ERRATA_BLFS_URL}"
show_packages BLFS "${PKG_LIST}"

rm -f "${TMP}" "${TMP_SORT}"
