#! /bin/bash

PRGNAME="bison"

### Bison
# Пакет предназначен для автоматического создания синтаксических анализаторов

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
make install
