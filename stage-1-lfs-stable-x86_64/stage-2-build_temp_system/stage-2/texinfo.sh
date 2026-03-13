#! /bin/bash

PRGNAME="texinfo"

### Texinfo
# Официальная система документации проекта GNU, используемая для создания
# руководств, которые можно читать и в консоли, и на бумаге.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure \
    --prefix=/usr || exit 1

make || make -j1 || exit 1
make install
