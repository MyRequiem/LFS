#! /bin/bash

PRGNAME="bison"

### Bison
# Генератор программ, который помогает разработчикам создавать инструменты для
# анализа и обработки сложных текстовых структур и языков программирования.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
make install
