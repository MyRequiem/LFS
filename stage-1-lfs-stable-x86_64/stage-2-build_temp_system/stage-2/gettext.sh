#! /bin/bash

PRGNAME="gettext"

### Gettext
# Утилиты для интернационализации и локализации, позволяющие программам
# компилироваться с NLS (Native Language Support), т.е. с поддержкой родного
# языка

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# на данный момент не нужно устанавливать какие-либо общие библиотеки Gettext,
# поэтому нет необходимости их создавать
#    --disable-shared
./configure \
    --disable-shared || exit 1

make || make -j1 || exit 1

# для временного набора инструментов нам нужно установить только три утилиты:
# msgfmt, msgmerge и xgettext
cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
