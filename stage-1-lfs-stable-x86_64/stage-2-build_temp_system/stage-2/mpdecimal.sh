#! /bin/bash

PRGNAME="mpdecimal"

### mpdecimal
# Библиотека на C/C++ для высокоточных вычислений с десятичными числами
# произвольной разрядности, исключающая ошибки округления двоичной арифметики.
# Является основой стандартного модуля decimal в языке Python.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
make install
