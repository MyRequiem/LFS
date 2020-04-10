#! /bin/bash

PRGNAME="tcl"
VERSION="8.6.9"
VER="$(echo "${VERSION}" | cut -d . -f 1,2)"

### Tcl
# Скриптовый язык со множеством встроенных функций, которые делают его очень
# удобным для написания интерактивных сценариев.

# http://www.linuxfromscratch.org/blfs/view/9.0/general/tcl.html

# Home page: http://www.tcl.tk/
# Download:  https://downloads.sourceforge.net/tcl/tcl8.6.9-src.tar.gz
#            ftp://ftp.tcl.tk/pub/tcl/tcl8_6/tcl8.6.9-src.tar.gz
#            https://downloads.sourceforge.net/tcl/tcl8.6.9-html.tar.gz

# Required: no
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

SOURCES="/sources"
BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf ${PRGNAME}${VERSION}

tar xvf "${SOURCES}/${PRGNAME}${VERSION}"-src.tar.?z*
cd "${PRGNAME}${VERSION}" || exit 1

SRCDIR="$(pwd)"
cd unix || exit 1

./configure                 \
    --prefix=/usr           \
    --mandir=/usr/share/man \
    --enable-64bit || exit 1

make || exit 1

sed -e "s#$SRCDIR/unix#/usr/lib#" \
    -e "s#$SRCDIR#/usr/include#"  \
    -i tclConfig.sh || exit 1

sed -e "s#$SRCDIR/unix/pkgs/tdbc1.1.0#/usr/lib/tdbc1.1.0#" \
    -e "s#$SRCDIR/pkgs/tdbc1.1.0/generic#/usr/include#"    \
    -e "s#$SRCDIR/pkgs/tdbc1.1.0/library#/usr/lib/tcl$VER#" \
    -e "s#$SRCDIR/pkgs/tdbc1.1.0#/usr/include#"            \
    -i pkgs/tdbc1.1.0/tdbcConfig.sh || exit 1

sed -e "s#$SRCDIR/unix/pkgs/itcl4.1.2#/usr/lib/itcl4.1.2#" \
    -e "s#$SRCDIR/pkgs/itcl4.1.2/generic#/usr/include#"    \
    -e "s#$SRCDIR/pkgs/itcl4.1.2#/usr/include#"            \
    -i pkgs/itcl4.1.2/itclConfig.sh || exit 1

# make test
make install
make install DESTDIR="${TMP_DIR}"
make install-private-headers
make install-private-headers DESTDIR="${TMP_DIR}"

ln -svf "tclsh${VER}" /usr/bin/tclsh
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -svf "tclsh${VER}" tclsh
)
chmod -v 755 "/usr/lib/libtcl${VER}.so"
chmod -v 755 "${TMP_DIR}/usr/lib/libtcl${VER}.so"

# документация
mkdir -pv "/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
tar xvf /sources/${PRGNAME}${VERSION}-html.tar.?z* --strip-components=1

cp -vR html/* "/usr/share/doc/${PRGNAME}-${VERSION}"
cp -vR html/* "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Tool Command Language)
#
# Tcl is a simple to use text-based script language with many built-in features
# which make it especially nice for writing interactive scripts.
#
# Home page: http://www.tcl.tk/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}${VERSION}-src.tar.gz
#            ftp://ftp.tcl.tk/pub/tcl/tcl8_6/${PRGNAME}${VERSION}-src.tar.gz
#            https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}${VERSION}-html.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
