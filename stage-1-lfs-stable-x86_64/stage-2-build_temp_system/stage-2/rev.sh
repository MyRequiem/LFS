#! /bin/bash

PRGNAME="rev"
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

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

./configure       \
    --prefix=/usr \
    --disable-liblastlog2 || exit 1

make rev
cp rev /usr/bin/
