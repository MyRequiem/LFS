#! /bin/bash

PRGNAME="ncurses"

### Ncurses (CRT screen handling and optimization package)
# Библиотека, написанная на языках Си и Ада, предназначенная для управления
# вводом-выводом на терминал. Так же библиотека позволяет задавать экранные
# координаты и цвет выводимых символов. Предоставляет программисту уровень
# абстракции, позволяющий не беспокоиться об аппаратных различиях терминалов и
# писать переносимый код

ROOT="/"
SOURCES="${ROOT}sources"
source "${ROOT}check_environment.sh" || exit 1

ARCH_VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.t?z" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 2- | cut -d - -f 1,2 | rev)"

BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}-${ARCH_VERSION}"

tar xvf "${SOURCES}/${PRGNAME}-${ARCH_VERSION}"*.t?z || exit 1
cd "${PRGNAME}-${ARCH_VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

VERSION="$(echo "${ARCH_VERSION}" | tr - .)"
TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# отключает сборку и установку большинства статических библиотек
#    --without-normal
# ключ генерирует и устанавливает файлы .pc для pkg-config
#    --enable-pc-files
./configure                 \
    --prefix=/usr           \
    --mandir=/usr/share/man \
    --with-shared           \
    --without-debug         \
    --without-normal        \
    --with-cxx-shared       \
    --enable-pc-files       \
    --with-pkg-config-libdir=/usr/lib/pkgconfig || exit 1

make || make -j1 || exit 1

# в состав пакета входят наборы тестов, но их можно запустить только после
# того, как пакет будет установлен

LIB_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
# установка пакета сразу в корень системы командой 'make install' перезапишет
# libncursesw.so.${LIB_VERSION} Это может привести к сбою настроек терминала и
# ошибки оболочки (Segmentation fault), которая будет пытаться использовать код
# и данные из прежней библиотеки. Установим пакет с помощью DESTDIR правильно
# заменив библиотеку libncursesw.so.${LIB_VERSION}
make DESTDIR="${PWD}/dest" install

# stripping
BINARY="$(find ./dest -type f -print0 | xargs -0 file 2>/dev/null | \
    /bin/grep -e "executable" -e "shared object" | /bin/grep ELF | \
    cut -f 1 -d :)"

for BIN in ${BINARY}; do
    strip --strip-unneeded "${BIN}" &>/dev/null
done

cp -vR dest/* "${TMP_DIR}"/

LIBNCURSESW="dest/usr/lib/libncursesw.so.${LIB_VERSION}"
install -vm755 "${LIBNCURSESW}" /usr/lib
rm -v "${LIBNCURSESW}"
sed -e 's/^#if.*XOPEN.*$/#if 1/' -i dest/usr/include/curses.h
cp -av dest/* /

# многие приложения все еще ожидают, что компоновщик сможет найти обычные
# libncurses.so, а не wide-character libncursesw.so библиотеки. Обманем такие
# приложения
for LIB in ncurses form panel menu ; do
    ln -sfv "lib${LIB}w.so" "/usr/lib/lib${LIB}.so"
    ln -sfv "${LIB}w.pc"    "/usr/lib/pkgconfig/${LIB}.pc"

    ln -sfv "lib${LIB}w.so" "${TMP_DIR}/usr/lib/lib${LIB}.so"
    ln -sfv "${LIB}w.pc"    "${TMP_DIR}/usr/lib/pkgconfig/${LIB}.pc"
done

ln -sfv libncursesw.so /usr/lib/libcurses.so
ln -sfv libncursesw.so "${TMP_DIR}/usr/lib/libcurses.so"

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
# Home page: https://www.gnu.org/software/${PRGNAME}/
# Download:  https://invisible-mirror.net/archives/${PRGNAME}/current/${PRGNAME}-${ARCH_VERSION}.tgz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
