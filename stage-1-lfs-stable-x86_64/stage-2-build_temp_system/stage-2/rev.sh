#! /bin/bash

PRGNAME="rev"
echo "Building ${PRGNAME}"
ARCH_NAME="util-linux"

### rev
# утилита из пакета util-linux, которая  посимвольно "переворачивает" строки

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

SOURCES="/sources"
BUILD_DIR="${SOURCES}/build"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${ARCH_NAME}"*

tar xvf "${SOURCES}/${ARCH_NAME}-"*.tar.?z* || exit 1
cd "${ARCH_NAME}"* || exit 1

./configure \
    --prefix=/usr || exit 1

make rev
cp rev /usr/bin
