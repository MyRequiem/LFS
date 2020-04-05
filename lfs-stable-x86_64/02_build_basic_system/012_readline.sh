#! /bin/bash

PRGNAME="readline"

### Readline
# Набор библиотек для редактирование из командной строки и возможности ведения
# истории

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/readline.html

# Home page: https://tiswww.case.edu/php/chet/readline/rltop.html
# Download:  http://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# переустановка Readline приведет к перемещению старых библиотек в
# <имя_библиотеки>.old. Хотя обычно это не проблема, в некоторых случаях это
# может вызвать ошибку компоновки в ldconfig. Этого можно избежать так:
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

# заставляет Readline связываться с библиотекой libncursesw
#    SHLIB_LIBS="-L/tools/lib -lncursesw"
make SHLIB_LIBS="-L/tools/lib -lncursesw" || exit 1

# установка пакета
make SHLIB_LIBS="-L/tools/lib -lncursesw" install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make SHLIB_LIBS="-L/tools/lib -lncursesw" install DESTDIR="${TMP_DIR}"

# теперь переместим динамические библиотеки в более подходящее место и исправим
# некоторые разрешения и символические ссылки
mv -v /usr/lib/lib{readline,history}.so.* /lib
chmod -v u+w /lib/lib{readline,history}.so.*
ln -sfv ../../lib/"$(readlink /usr/lib/libreadline.so)" /usr/lib/libreadline.so
ln -sfv ../../lib/"$(readlink /usr/lib/libhistory.so)" /usr/lib/libhistory.so

(
    cd "${TMP_DIR}" || exit 1
    mkdir -pv lib
    mv -v usr/lib/lib{readline,history}.so.* lib/
    chmod -v u+w lib/lib{readline,history}.so.*

    ln -sfv ../../lib/"$(readlink usr/lib/libreadline.so)" \
        usr/lib/libreadline.so
    ln -sfv ../../lib/"$(readlink usr/lib/libhistory.so)" \
        usr/lib/libhistory.so
)

# устновим документацию
install -v -m644 doc/*.{ps,pdf,html,dvi} "/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -m644 doc/*.{ps,pdf,html,dvi} \
    "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
# удалим не нужную документацию
rm -rf /usr/share/doc/readline
rm -rf "${TMP_DIR}/usr/share/doc/readline"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (line input library with editing features)
#
# The GNU Readline library provides a set of functions for use by applications
# that allow users to edit command lines as they are typed in. Both Emacs and
# vi editing modes are available. The Readline library includes additional
# functions to maintain a list of previously entered command lines, to recall
# and perhaps edit those lines, and perform csh-like history expansion on
# previous commands.
#
# Home page: https://tiswww.case.edu/php/chet/readline/rltop.html
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
