#! /bin/bash

PRGNAME="hstr"

### hstr (BASH and Zsh Shell History Suggest Box)
# Утилита командной строки для поиска по истории и автозавершения команд. Проще
# и эффективнее чем Ctrl-r

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${MAJ_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим пути к заголовкам ncurses
#    #include <ncursesw/curses.h> -> #include <curses.h>
sed 's/ncursesw\///' -i src/include/hstr.h        || exit 1
sed 's/ncursesw\///' -i src/include/hstr_curses.h || exit 1

autoreconf -vfis || exit 1

ac_cv_func_malloc_0_nonnull=yes \
./configure                     \
    --prefix=/usr               \
    --sysconfdir=/etc           \
    --localstatedir=/var        \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/bin
#    hh -> hstr
ln -svf ${PRGNAME} "${TMP_DIR}/usr/bin/hh"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (BASH and Zsh Shell History Suggest Box)
#
# BASH and Zsh Shell history suggest box is a command line utility that brings
# improved command completion from the history. It aims to make completion
# easier and more efficient than Ctrl-r
#
# Home page: https://github.com/dvorka/${PRGNAME}
# Download:  https://github.com/dvorka/${PRGNAME}/archive/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
