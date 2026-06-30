#! /bin/bash

PRGNAME="hstr"

### hstr (BASH and Zsh Shell History Suggest Box)
# Интерактивная консольная утилита, которая кардинально улучшает поиск по
# истории ранее введенных команд в терминалах Bash и Zsh. Она позволяет
# находить старые команды по ключевым словам на лету. Проще и эффективнее чем
# <Ctrl-r>.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

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

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# ссылка в /usr/bin
#    hh -> hstr
ln -svf ${PRGNAME} "${TMP_DIR}/usr/bin/hh"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (BASH and Zsh Shell History Suggest Box)
#
# BASH and Zsh Shell history suggest box is a command line utility that brings
# improved command completion from the history. It aims to make completion
# easier and more efficient than Ctrl-r
#
# Home page: https://github.com/dvorka-oss/${PRGNAME}/
# Download:  https://github.com/dvorka-oss/${PRGNAME}/archive/refs/tags/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
