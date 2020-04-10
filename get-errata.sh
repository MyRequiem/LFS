#! /bin/bash

VERSION="stable"
BOOK_URL="http://www.linuxfromscratch.org"
ERRATA_LFS_URL="${BOOK_URL}/lfs"
ERRATA_BLFS_URL="${BOOK_URL}/blfs"
LGREEN="\033[1;32m"
BROWN="\033[0;33m"
LBLUE="\033[1;34m"
RESET="\033[0m"
MOVE_CURS_TO_27_COL="\033[27G"

show_packages() {
    echo -e "${LGREEN}$1${RESET}"

    BASE_URL="${ERRATA_LFS_URL}"
    [[ "$1" == "BLFS" ]] && BASE_URL="${ERRATA_BLFS_URL}"

    for PKG in $2; do
        PKGNAME="$(echo "${PKG}" | cut -d \> -f 2)"
        URL="${BASE_URL}/$(echo "${PKG}" | cut -d / -f 3- | \
            cut -d \" -f 1)"
        echo -e "${BROWN}${PKGNAME}${MOVE_CURS_TO_27_COL}${LBLUE}${URL}${RESET}"
    done
}

get_pkg_list() {
    PKG_LIST="$(wget -q -O - "$1/errata/${VERSION}/" | \
        grep '<a href="../../view/' | grep -v "development version of the" | \
        cut -d \" -f 2- | cut -d \< -f 1 | sort)"
}

get_pkg_list "${ERRATA_LFS_URL}"
show_packages LFS "${PKG_LIST}"
echo ""
get_pkg_list "${ERRATA_BLFS_URL}"
show_packages BLFS "${PKG_LIST}"
