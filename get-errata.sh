#! /bin/bash

VERSION="stable"
BOOK_URL="http://www.linuxfromscratch.org"
ERRATA_LFS_URL="${BOOK_URL}/lfs"
ERRATA_BLFS_URL="${BOOK_URL}/blfs"
LGREEN="\033[1;32m"
BROWN="\033[0;33m"
LBLUE="\033[1;34m"
RESET="\033[0m"
MOVE_CURS_TO_30_COL="\033[30G"
TMP="/tmp/lfs-errata.tmp"

show_packages() {
    echo -e "${LGREEN}$1${RESET}"

    BASE_URL="${ERRATA_LFS_URL}"
    [[ "$1" == "BLFS" ]] && BASE_URL="${ERRATA_BLFS_URL}"

    /bin/false > "${TMP}"
    for PKG in $2; do
        if [[ $PKG =~ http:// ]]; then
            PKGNAME="$(echo "${PKG}" | rev | cut -d / -f 1 | rev | \
                cut -d - -f 1,2)"
            URL="$(echo "${PKG}" | cut -d \" -f 1)"
            # переводим всю строку в нижний регистр
            echo "${PKGNAME} ${URL}" | tr '[:upper:]' '[:lower:]' >> "${TMP}"
        else
            PKGNAME="$(echo "${PKG}" | cut -d \> -f 2)"
            URL="${BASE_URL}/$(echo "${PKG}" | cut -d / -f 3- | \
                cut -d \" -f 1)"
            # переводим всю строку в нижний регистр
            echo "${PKGNAME} ${URL}" | tr '[:upper:]' '[:lower:]' >> "${TMP}"
        fi
    done

    {
        while read -r LINE; do
            PKGNAME="$(echo "${LINE}" | cut -d " " -f 1)"
            URL="$(echo "${LINE}" | cut -d " " -f 2)"
            echo -en "${BROWN}${PKGNAME}${MOVE_CURS_TO_30_COL}"
            echo -e  "${LBLUE}${URL}${RESET}"
        done
    } < "${TMP}" | sort
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

rm -f "${TMP}"
