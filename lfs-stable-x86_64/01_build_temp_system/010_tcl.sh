#! /bin/bash

PRGNAME="tcl"

### Tcl
# TCL - Tool Command Language
# Этот пакет и два следующих (Expect и DejaGNU) установливаем для поддержки
# запуска тестовых наборов для GCC, Binutils и других пакетов в дальнейшем.

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter05/tcl.html

# Home page: http://tcl.sourceforge.net/
# Download:  https://downloads.sourceforge.net/tcl/tcl8.6.9-src.tar.gz

source "$(pwd)/check_environment.sh" || exit 1

SOURCES="${LFS}/sources"
VERSION=$(echo "${SOURCES}/${PRGNAME}"*.tar.?z* | rev | cut -d / -f 1 | \
    rev | cut -d - -f 1 | cut -d l -f 2)
BUILD_DIR="${SOURCES}/build"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}${VERSION}"

tar xvf "${SOURCES}/${PRGNAME}${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}${VERSION}" || exit 1

cd unix || exit 1
./configure \
    --prefix=/tools || exit 1

make || make -j1 || exit 1

# запускаем тестовый набор для Tcl
TZ=UTC make test

make install

# сделаем установленную библиотеку доступной для записи, чтобы позже можно было
# удалить отладочную информацию (debugging symbols)
chmod -v u+w /tools/lib/libtcl8.6.so

# устанавливаем заголовки для TCL. Они потребуются для сборки следующего пакета
# Expect
make install-private-headers
# создаем символическую ссылку в /tools/bin/ tclsh -> tclsh8.6
ln -sv tclsh8.6 /tools/bin/tclsh
