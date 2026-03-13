#! /bin/bash

PRGNAME="readline"

### Readline (line input library with editing features)
# Библиотека, позволяющая пользователю редактировать вводимые команды и
# просматривать историю команд в терминале.

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# переустановка Readline приведет к перемещению старых библиотек в
# <имя_библиотеки>.old. Хотя обычно это не проблема, в некоторых случаях это
# может вызвать ошибку компоновки в ldconfig. Этого можно избежать так:
sed -i '/MV.*old/d'    Makefile.in           || exit 1
sed -i '/{OLDSUFF}/c:' support/shlib-install || exit 1

# запретим жестко кодировать пути поиска библиотек (rpath) в общие библиотеки,
# т.к. этому пакету не требуется rpath для установки в стандартное
# расположение, и rpath может иногда вызывать нежелательные эффекты или даже
# проблемы безопасности
sed -i 's/-Wl,-rpath,[^ ]*//' support/shobj-conf

# исправим проблему, обнаруженную в исходниках
sed -e '270a\
     else\
       chars_avail = 1;'      \
    -e '288i\   result = -1;' \
    -i.orig input.c

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

# сразу устанавливаем в систему, иначе отвалится консоль
make install
make install DESTDIR="${TMP_DIR}"

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
# Home page: https://tiswww.case.edu/php/chet/${PRGNAME}/rltop.html
# Download:  https://ftpmirror.gnu.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
