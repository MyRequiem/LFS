#! /bin/bash

PRGNAME="readline"

### Readline (line input library with editing features)
# Набор библиотек для редактирование из командной строки и возможности ведения
# истории

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/lib"

# переустановка Readline приведет к перемещению старых библиотек в
# <имя_библиотеки>.old. Хотя обычно это не проблема, в некоторых случаях это
# может вызвать ошибку компоновки в ldconfig. Этого можно избежать так:
sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

# сообщает Readline, что он может найти функции библиотеки termcap в библиотеке
# curses, а не в отдельной библиотеке termcap, что позволяет создать правильный
# /usr/lib/pkgconfig/readline.pc
#    --with-curses
./configure          \
    --prefix=/usr    \
    --disable-static \
    --with-curses    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

# заставляет Readline связываться с библиотекой libncursesw
#    SHLIB_LIBS="-lncursesw"
make SHLIB_LIBS="-lncursesw" || make -j1 SHLIB_LIBS="-lncursesw" || exit 1

# пакет не имеет набора тестов

make SHLIB_LIBS="-lncursesw" install DESTDIR="${TMP_DIR}"

# переместим динамические библиотеки в более подходящее место и исправим
# некоторые разрешения и символические ссылки
(
    cd "${TMP_DIR}" || exit 1
    mv -v usr/lib/lib{readline,history}.so.* lib/

    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -svf "../../lib/$(readlink libreadline.so)" libreadline.so
    ln -svf "../../lib/$(readlink libhistory.so)"  libhistory.so
)

# устновим html-документацию
install -v -m644 doc/*.html "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
# удалим не нужную документацию
rm -rf "${TMP_DIR}/usr/share/doc/readline"

rm -f "${TMP_DIR}/usr/share/info/dir"

/bin/cp -vR "${TMP_DIR}"/* /

# система документации Info использует простые текстовые файлы в
# /usr/share/info/, а список этих файлов хранится в файле /usr/share/info/dir
# который мы обновим
cd /usr/share/info || exit 1
rm -fv dir
for FILE in *; do
    install-info "${FILE}" dir 2>/dev/null
done

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

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
