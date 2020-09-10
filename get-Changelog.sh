#! /bin/bash

if [[ "$(whoami)" == "root" ]]; then
    echo "This script needs to be run as a regular user (not root)"
    exit 1
fi

BOOK_URL="http://www.linuxfromscratch.org"
LFS_URL="${BOOK_URL}/lfs/view/stable/chapter01/changelog.html"
BLFS_URL="${BOOK_URL}/blfs/view/stable/introduction/changelog.html"

CHANGELOG_LFS="lfs-stable-x86_64/Changelog"
CHANGELOG_BLFS="blfs-stable-x86_64/Changelog"

w3m -dump "${LFS_URL}"  > "${CHANGELOG_LFS}.new"
w3m -dump "${BLFS_URL}" > "${CHANGELOG_BLFS}.new"

if ! [ -e "${CHANGELOG_LFS}" ]; then
    mv "${CHANGELOG_LFS}.new" "${CHANGELOG_LFS}"
fi

if ! [ -e "${CHANGELOG_BLFS}" ]; then
    mv "${CHANGELOG_BLFS}.new" "${CHANGELOG_BLFS}"
fi

if [[ -e "${CHANGELOG_LFS}" && -e "${CHANGELOG_LFS}.new" ]]; then
    diff -U 1 "${CHANGELOG_LFS}" "${CHANGELOG_LFS}.new" > \
        "${CHANGELOG_LFS}.diff"
    rm "${CHANGELOG_LFS}"
    mv "${CHANGELOG_LFS}.new" "${CHANGELOG_LFS}"

    echo -e "LFS: ${LFS_URL}\n-----------------------"
    cat "${CHANGELOG_LFS}.diff"
    rm -f "${CHANGELOG_LFS}.diff"
    echo ""
fi

if [[ -e "${CHANGELOG_BLFS}" && -e "${CHANGELOG_BLFS}.new" ]]; then
    diff -U 1 "${CHANGELOG_BLFS}" "${CHANGELOG_BLFS}.new" > \
        "${CHANGELOG_BLFS}.diff"
    rm "${CHANGELOG_BLFS}"
    mv "${CHANGELOG_BLFS}.new" "${CHANGELOG_BLFS}"

    echo -e "BLFS: ${BLFS_URL}\n-----------------------"
    cat "${CHANGELOG_BLFS}.diff"
    rm -f "${CHANGELOG_BLFS}.diff"
    echo ""
fi
