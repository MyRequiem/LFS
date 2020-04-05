#! /bin/bash

SRC_ARCH_NAME="$1"
VERSION="$2"
SOURCES="/sources"
BUILD_DIR="${SOURCES}/build"
if [ -z "${VERSION}" ]; then
    VERSION="$(echo "${SOURCES}/${SRC_ARCH_NAME}"-*.tar.?z* | rev | \
        cut -d . -f 3- | cut -d - -f 1 | rev)"
fi

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${SRC_ARCH_NAME}-${VERSION}"

tar xvf "${SOURCES}/${SRC_ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${SRC_ARCH_NAME}-${VERSION}" || exit 1
