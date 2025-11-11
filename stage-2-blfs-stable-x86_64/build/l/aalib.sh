#! /bin/bash

PRGNAME="aalib"
VERSION="1.4rc5"
DIR_VERSION="1.4.0"

### AAlib (ASCII Art library)
# Библиотека, которая отображает любую графику в ASCII символах.

# Required:    no
# Recommended: no
# Optional:    xorg-libraries   (runtime)
#              xorg-fonts       (runtime)
#              slang
#              gpm

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${DIR_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

# исправим небольшую проблему с aalib.m4
sed -i -e '/AM_PATH_AALIB,/s/AM_PATH_AALIB/[&]/' aalib.m4 || exit 1

# изменим шрифты с Xorg Legacy на шрифты Xorg Fonts:
sed -e 's/8x13bold/-*-luxi mono-bold-r-normal--13-120-*-*-m-*-*-*/' \
    -i src/aax.c || exit 1

# исправим чрезмерное использование некоторых внутренних структур данных,
# позволяющих создавать этот пакет с Ncurses-6.5 или более поздней версии:
sed 's/stdscr->_max\([xy]\) + 1/getmax\1(stdscr)/' -i src/aacurses.c || exit 1

# для сборки пакета с GCC>=14, добавим несколько отсутствующих директив
# #include и исправим некорректный оператор return, чтобы сделать код
# совместимым с C99. Затем восстановим скрипт configure, чтобы код C был также
# совместим с C99:
sed -i '1i#include <stdlib.h>'                   \
    src/aa{fire,info,lib,linuxkbd,savefont,test,regist}.c || exit 1
sed -i '1i#include <string.h>'                   \
    src/aa{kbdreg,moureg,test,regist}.c                   || exit 1
sed -i '/X11_KBDDRIVER/a#include <X11/Xutil.h>'  \
    src/aaxkbd.c                                          || exit 1
sed -i '/rawmode_init/,/^}/s/return;/return 0;/' \
    src/aalinuxkbd.c                                      || exit 1

autoconf || exit 1
./configure                   \
    --prefix=/usr             \
    --infodir=/usr/share/info \
    --mandir=/usr/share/man   \
    --with-ncurses=/usr       \
    --disable-static || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (ASCII Art library)
#
# AA-lib is an ASCII art graphics library which render any graphic into ASCII
# Art. Internally, the AA-lib API is similar to other graphics libraries, but
# it renders the the output into ASCII art.
#
# Home page: https://aa-project.sourceforge.net/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/aa-project/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
