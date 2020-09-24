#! /bin/bash

PRGNAME="ncurses"

### Ncurses (CRT screen handling and optimization package)
# Библиотека, написанная на языках Си и Ада, предназначенная для управления
# вводом-выводом на терминал. Так же библиотека позволяет задавать экранные
# координаты и цвет выводимых символов. Предоставляет программисту уровень
# абстракции, позволяющий не беспокоиться об аппаратных различиях терминалов и
# писать переносимый код

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/ncurses.html

# Home page: http://www.gnu.org/software/ncurses/

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"{/lib,"${DOCS}"}

# не устанавливаем статическую библиотеку, установка которой полностью не
# контролируется параметрами скрипта 'configure'
sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in

# заставляет собирать wide-character библиотеки (например, libncursesw.so)
# вместо обычных (libncurses.so). Такие wide-character библиотеки можно
# использовать как в многобайтовых, так и в традиционных 8-битных локалях,
# тогда как обычные библиотеки правильно работают только в 8-битных локалях
#    --enable-widec
# ключ генерирует и устанавливает файлы .pc для pkg-config
#    --enable-pc-files
# отключает сборку и установку большинства статических библиотек
#    --without-normal
./configure                 \
    --prefix=/usr           \
    --mandir=/usr/share/man \
    --with-shared           \
    --without-debug         \
    --without-normal        \
    --enable-pc-files       \
    --enable-widec || exit 1

make || make -j1 || exit 1

# в состав пакета входят наборы тестов, но их можно запустить только после
# того, как пакет будет установлен

# устанавливаем сразу в систему и во временную директорию, иначе при
# копировании с ${TMP_DIR} в корень выдаст ошибку "Segmentation fault" из-за
# сбоя настроек терминала
make install
make install DESTDIR="${TMP_DIR}"

# переместим библиотеки из /usr/lib в /lib
mv -v /usr/lib/libncursesw.so.6* /lib
mv "${TMP_DIR}/usr/lib/libncursesw.so.6"* "${TMP_DIR}/lib/"

# исправим ссылку в /usr/lib
#    libncursesw.so -> ../../lib/libncursesw.so.${VERSION}
ln -sfv "../../lib/$(readlink /usr/lib/libncursesw.so)" /usr/lib/libncursesw.so
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv "../../lib/$(readlink libncursesw.so)" libncursesw.so
)

# многие приложения все еще ожидают, что компоновщик сможет найти обычные, а не
# wide-character Ncurses библиотеки. Обманем такие приложения:
for LIB in ncurses form panel menu ; do
    rm -vf                    "/usr/lib/lib${LIB}.so"
    echo "INPUT(-l${LIB}w)" > "/usr/lib/lib${LIB}.so"
    ln -sfv "${LIB}w.pc"      "/usr/lib/pkgconfig/${LIB}.pc"

    rm -fv                    "${TMP_DIR}/usr/lib/lib${LIB}.so"
    echo "INPUT(-l${LIB}w)" > "${TMP_DIR}/usr/lib/lib${LIB}.so"
    (
        cd "${TMP_DIR}/usr/lib/pkgconfig" || exit 1
        ln -sfv "${LIB}w.pc" "${LIB}.pc"

    )
done

# то же самое для старых приложений, которые ищут -lcurses, а не -lncurses
rm -vf                     /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so      /usr/lib/libcurses.so

rm -vf                     "${TMP_DIR}/usr/lib/libcursesw.so"
echo "INPUT(-lncursesw)" > "${TMP_DIR}/usr/lib/libcursesw.so"
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    ln -sfv libncurses.so libcurses.so
)

# установим документацию
mkdir -v        "${DOCS}"
cp -vR    doc/* "${DOCS}"
cp -vR    doc/* "${TMP_DIR}${DOCS}"

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

cp -av lib/lib*.so.5* /usr/lib
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
