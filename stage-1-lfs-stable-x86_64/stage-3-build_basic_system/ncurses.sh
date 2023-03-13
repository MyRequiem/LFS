#! /bin/bash

PRGNAME="ncurses"

### Ncurses (CRT screen handling and optimization package)
# Библиотека, написанная на языках Си и Ада, предназначенная для управления
# вводом-выводом на терминал. Так же библиотека позволяет задавать экранные
# координаты и цвет выводимых символов. Предоставляет программисту уровень
# абстракции, позволяющий не беспокоиться об аппаратных различиях терминалов и
# писать переносимый код

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# отключает сборку и установку большинства статических библиотек
#    --without-normal
# ключ генерирует и устанавливает файлы .pc для pkg-config
#    --enable-pc-files
# заставляет собирать wide-character библиотеки (например, libncursesw.so)
# вместо обычных (libncurses.so). Такие wide-character библиотеки можно
# использовать как в многобайтовых, так и в традиционных 8-битных локалях,
# тогда как обычные библиотеки правильно работают только в 8-битных локалях
#    --enable-widec
./configure                 \
    --prefix=/usr           \
    --mandir=/usr/share/man \
    --with-shared           \
    --without-debug         \
    --without-normal        \
    --with-cxx-shared       \
    --enable-pc-files       \
    --enable-widec          \
    --with-pkg-config-libdir=/usr/lib/pkgconfig || exit 1

make || make -j1 || exit 1

# в состав пакета входят наборы тестов, но их можно запустить только после
# того, как пакет будет установлен

# установка пакета сразу в корень системы командой 'make install' перезапишет
# libncursesw.so.${VERSION} Это может привести к сбою настроек терминала и
# ошибки оболочки (Segmentation fault), которая будет пытаться использовать код
# и данные из прежней библиотеки. Установим пакет с помощью DESTDIR правильно
# заменив файл библиотеки:
make install DESTDIR="${PWD}/dest"

# stripping
BINARY="$(find ./dest -type f -print0 | xargs -0 file 2>/dev/null | \
    /bin/grep -e "executable" -e "shared object" | /bin/grep ELF | \
    cut -f 1 -d :)"

for BIN in ${BINARY}; do
    strip --strip-unneeded "${BIN}" &>/dev/null
done

cp -vR dest/* "${TMP_DIR}"/

LIBNCURSESW="dest/usr/lib/libncursesw.so.${VERSION}"
install -vm755 "${LIBNCURSESW}" /usr/lib
rm -v  "${LIBNCURSESW}"
cp -av dest/* /

# многие приложения все еще ожидают, что компоновщик сможет найти обычные
# libncurses.so, а не wide-character libncursesw.so библиотеки. Обманем такие
# приложения:
for LIB in ncurses form panel menu ; do
    rm -vf                    "/usr/lib/lib${LIB}.so"
    echo "INPUT(-l${LIB}w)" > "/usr/lib/lib${LIB}.so"
    ln -sfv "${LIB}w.pc"      "/usr/lib/pkgconfig/${LIB}.pc"
    chmod 755 "/usr/lib/lib${LIB}.so"

    rm -fv                    "${TMP_DIR}/usr/lib/lib${LIB}.so"
    echo "INPUT(-l${LIB}w)" > "${TMP_DIR}/usr/lib/lib${LIB}.so"
    chmod 755 "${TMP_DIR}/usr/lib/lib${LIB}.so"
    (
        cd "${TMP_DIR}/usr/lib/pkgconfig" || exit 1
        ln -sfv "${LIB}w.pc" "${LIB}.pc"

    )
done

# то же самое для старых приложений, которые ищут -lcurses, а не -lncurses
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so
chmod 755 /usr/lib/libcursesw.so

rm -vf                     "${TMP_DIR}/usr/lib/libcursesw.so"
echo "INPUT(-lncursesw)" > "${TMP_DIR}/usr/lib/libcursesw.so"
chmod 755 "${TMP_DIR}/usr/lib/libcursesw.so"
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv libncurses.so libcurses.so
)

# снова соберем пакет для построения 5 версии библиотеки, которая все еще
# требуется некоторым программам
make distclean
./configure               \
    --prefix=/usr         \
    --with-shared         \
    --without-normal      \
    --without-debug       \
    --without-cxx-binding \
    --with-abi-version=5 || exit 1

make sources libs || make -j1 sources libs || exit 1

# stripping
BINARY="$(find lib/ -type f -name "*.so.5*" -print0 | \
    xargs -0 file 2>/dev/null | /bin/grep -e "executable" -e "shared object" | \
    /bin/grep ELF | cut -f 1 -d :)"

for BIN in ${BINARY}; do
    strip --strip-unneeded "${BIN}" &>/dev/null
done

cp -av lib/lib*.so.5* /usr/lib/
cp -av lib/lib*.so.5* "${TMP_DIR}/usr/lib/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (CRT screen handling and optimization package)
#
# The ncurses (new curses) library is a free software emulation of curses in
# System V Release 4.0, and more. Package contains libraries for
# terminal-independent handling of character screens. It uses terminfo format,
# supports pads and color and multiple highlights and forms characters and
# function-key mapping, and has all the other SYSV-curses enhancements over BSD
# curses.
#
# Home page: http://www.gnu.org/software/${PRGNAME}/
# Download:  http://ftp.gnu.org/gnu/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
