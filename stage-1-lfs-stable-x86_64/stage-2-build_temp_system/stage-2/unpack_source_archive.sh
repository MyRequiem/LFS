#! /bin/bash

SRC_ARCH_NAME="$1"
SOURCES="/sources"
VERSION="$(echo "${SOURCES}/${SRC_ARCH_NAME}"-*.tar.?z* | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"
BUILD_DIR="${SOURCES}/build"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${SRC_ARCH_NAME}-${VERSION}"

tar xvf "${SOURCES}/${SRC_ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${SRC_ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;
