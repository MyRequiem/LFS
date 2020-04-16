#! /bin/bash

SRC_ARCH_NAME="$1"
VERSION="$2"
SOURCES="/root/src"

if [ -z "${VERSION}" ]; then
    ARCH_TYPE=".tar.?z"
    VERSION="$(find ${SOURCES} -type f -name "${SRC_ARCH_NAME}-*.tar.?z*" \
        2>/dev/null | head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"
fi

if [ -z "${VERSION}" ]; then
    ARCH_TYPE=".t?z"
    VERSION="$(find ${SOURCES} -type f -name "${SRC_ARCH_NAME}-*.t?z" \
        2>/dev/null | head -n 1 | rev | cut -d . -f 2- | cut -d - -f 1 | rev)"
fi

if [ -z "${VERSION}" ]; then
    ARCH_TYPE=".zip"
    VERSION="$(find ${SOURCES} -type f -name "${SRC_ARCH_NAME}-*.zip" \
        2>/dev/null | head -n 1 | rev | cut -d . -f 2- | cut -d - -f 1 | rev)"
fi

if [ -z "${VERSION}" ]; then
    echo "Can not determine the package version of ${SRC_ARCH_NAME}"
    exit 1
fi

BUILD_DIR="/tmp/build-${SRC_ARCH_NAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

if [[ "${ARCH_TYPE}" == ".tar.?z" ]]; then
    tar xvf "${SOURCES}/${SRC_ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
elif [[ "${ARCH_TYPE}" == ".t?z" ]]; then
    tar xvf "${SOURCES}/${SRC_ARCH_NAME}-${VERSION}"*.t?z || exit 1
elif [[ "${ARCH_TYPE}" == ".zip" ]]; then
    unzip -d "${SRC_ARCH_NAME}-${VERSION}" \
        "${SOURCES}/${SRC_ARCH_NAME}-${VERSION}"*.zip || exit 1
fi

cd "${SRC_ARCH_NAME}-${VERSION}" || exit 1
