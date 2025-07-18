#! /bin/bash

PRGNAME="tcl"

### Tcl (Tool Command Language)
# Скриптовый язык со множеством встроенных функций, которые делают его очень
# удобным для написания интерактивных сценариев. Этот пакет и два следующих
# (Expect и DejaGNU) необходимы для поддержки запуска тестовых наборов.

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

SOURCES="${ROOT}sources"
VERSION=$(echo "${SOURCES}/${PRGNAME}"*-src.tar.?z* | rev | cut -d / -f 1 | \
    rev | cut -d - -f 1 | cut -d l -f 2)

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}${VERSION}"

tar xvf "${SOURCES}/${PRGNAME}"*-src.tar.?z* || exit 1
cd "${PRGNAME}${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

SRCDIR="$(pwd)"
cd unix || exit 1
./configure                 \
    --prefix=/usr           \
    --mandir=/usr/share/man \
    --disable-rpath || exit 1

make || make -j1 || exit 1

# удаляем ссылки на каталог сборки из файлов конфигурации и заменяем их на
# каталог установки
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
sed -e "s|$SRCDIR/unix|/usr/lib|" \
    -e "s|$SRCDIR|/usr/include|"  \
    -i tclConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.7|/usr/lib/tdbc1.1.7|"            \
    -e "s|$SRCDIR/pkgs/tdbc1.1.7/generic|/usr/include|"               \
    -e "s|$SRCDIR/pkgs/tdbc1.1.7/library|/usr/lib/tcl${MAJ_VERSION}|" \
    -e "s|$SRCDIR/pkgs/tdbc1.1.7|/usr/include|"                       \
    -i pkgs/tdbc1.1.7/tdbcConfig.sh

sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.4|/usr/lib/itcl4.2.4|" \
    -e "s|$SRCDIR/pkgs/itcl4.2.4/generic|/usr/include|"    \
    -e "s|$SRCDIR/pkgs/itcl4.2.4|/usr/include|"            \
    -i pkgs/itcl4.2.4/itclConfig.sh

# make test

make install DESTDIR="${TMP_DIR}"

# сделаем установленную библиотеку доступной для записи, чтобы позже можно было
# удалить отладочную информацию (debugging symbols)
chmod -v u+w "${TMP_DIR}/usr/lib/libtcl${MAJ_VERSION}.so"

# устанавливаем заголовки, которые требуются для сборки пакета Expect
make install-private-headers DESTDIR="${TMP_DIR}"

# создаем символическую ссылку в /usr/bin/
#    tclsh -> tclsh${MAJ_VERSION}
ln -sfv "tclsh${MAJ_VERSION}" "${TMP_DIR}/usr/bin/tclsh"

# переименуем man-страницу Thread.3 в Tcl_Thread.3, т.к. страница Thread.3
# устанавливается с пакетом Perl
mv "${TMP_DIR}/usr/share/man/man3"/{Thread,Tcl_Thread}.3

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Tool Command Language)
#
# Tcl is a simple to use text-based script language with many built-in features
# which make it especially nice for writing interactive scripts.
#
# Home page: https://www.tcl.tk/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}${VERSION}-src.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
