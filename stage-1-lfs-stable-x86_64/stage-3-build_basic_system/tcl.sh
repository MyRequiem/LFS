#! /bin/bash

PRGNAME="tcl"

### Tcl (Tool Command Language)
# Скриптовый язык со множеством встроенных функций, которые делают его очень
# удобным для написания интерактивных сценариев. Этот пакет и два следующих
# (Expect и DejaGNU) необходимы для поддержки запуска тестовых наборов.

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/tcl.html

# Home page: http://tcl.sourceforge.net/

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

SOURCES="${ROOT}sources"
VERSION=$(echo "${SOURCES}/${PRGNAME}"*-src.tar.?z* | rev | cut -d / -f 1 | \
    rev | cut -d - -f 1 | cut -d l -f 2)

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}${VERSION}"

tar xvf "${SOURCES}/${PRGNAME}"*-src.tar.?z* || exit 1
cd "${PRGNAME}${VERSION}" || exit 1

SRCDIR="$(pwd)"
cd unix || exit 1
./configure        \
    --prefix=/usr  \
    --enable-64bit \
    --mandir=/usr/share/man || exit 1

make || make -j1 || exit 1

# удаляем ссылки на каталог сборки из файлов конфигурации и заменяем их на
# каталог установки
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
sed -e "s|${SRCDIR}/unix|/usr/lib|" \
    -e "s|${SRCDIR}|/usr/include|"  \
    -i tclConfig.sh || exit 1

sed -e "s|${SRCDIR}/unix/pkgs/tdbc1.1.1|/usr/lib/tdbc1.1.1|" \
    -e "s|${SRCDIR}/pkgs/tdbc1.1.1/generic|/usr/include|"    \
    -e "s|${SRCDIR}/pkgs/tdbc1.1.1/library|/usr/lib/tcl${MAJ_VERSION}|" \
    -e "s|${SRCDIR}/pkgs/tdbc1.1.1|/usr/include|"            \
    -i pkgs/tdbc1.1.1/tdbcConfig.sh || exit 1

sed -e "s|${SRCDIR}/unix/pkgs/itcl4.2.0|/usr/lib/itcl4.2.0|" \
    -e "s|${SRCDIR}/pkgs/itcl4.2.0/generic|/usr/include|"    \
    -e "s|${SRCDIR}/pkgs/itcl4.2.0|/usr/include|"            \
    -i pkgs/itcl4.2.0/itclConfig.sh || exit 1

# запускаем тестовый набор Tcl
# make test

make install DESTDIR="${TMP_DIR}"

# сделаем установленную библиотеку доступной для записи, чтобы позже можно было
# удалить отладочную информацию (debugging symbols)
chmod -v u+w "${TMP_DIR}/usr/lib/libtcl${MAJ_VERSION}".so

# устанавливаем заголовки, которые требуются для сборки пакета Expect
make install-private-headers DESTDIR="${TMP_DIR}"

# создаем символическую ссылку в /usr/bin/ tclsh -> tclsh${MAJ_VERSION}
ln -sv "tclsh${MAJ_VERSION}" "${TMP_DIR}/usr/bin/tclsh"

# установим документацию
tar xvf "${SOURCES}/${PRGNAME}${VERSION}"-html.tar.?z* --strip-components=1 \
    -C "${TMP_DIR}${DOCS}" || exit 1

/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Tool Command Language)
#
# Tcl is a simple to use text-based script language with many built-in features
# which make it especially nice for writing interactive scripts.
#
# Home page: http://www.tcl.tk/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}${VERSION}-src.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
