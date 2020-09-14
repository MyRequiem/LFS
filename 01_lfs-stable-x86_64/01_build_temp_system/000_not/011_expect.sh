#! /bin/bash

PRGNAME="expect"

### Expect
# Пакет содержит программу для ведения диалоговых сценариев с другими
# интерактивными программами

# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html

# Home page: https://core.tcl.tk/expect/
# Download:  https://prdownloads.sourceforge.net/expect/expect5.45.4.tar.gz

source "$(pwd)/check_environment.sh" || exit 1

SOURCES="${LFS}/sources"
VERSION=$(echo "${SOURCES}/${PRGNAME}"*.tar.?z* | rev | cut -d / -f 1 | \
    cut -d . -f 3- | rev | cut -d t -f 2)
BUILD_DIR="${SOURCES}/build"

mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}${VERSION}"

tar xvf "${SOURCES}/${PRGNAME}${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}${VERSION}" || exit 1

# заставим скрипт конфигурации expect использовать /bin/stty вместо
# /usr/local/bin/stty, который он может найти в хост-системе
cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure

### Конфигурация
# скрипт configure будет искать установленный Tcl в директории временных
# инструментов, а не в хост-системе
#    --with-tcl=/tools/lib
# явно указываем, где искать внутренние заголовки Tcl
#    --with-tclinclude=/tools/include
./configure               \
    --prefix=/tools       \
    --with-tcl=/tools/lib \
    --with-tclinclude=/tools/include || exit 1

make || make -j1 || exit 1

# запускаем тесты
make test

# устанавливаем пакет, но предотвращаем установку дополнительных сценариев
# Expect, которые не нужны в данный момент
#    SCRIPTS=""
make SCRIPTS="" install
