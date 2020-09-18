#! /bin/bash

PRGNAME="tcl"
VERSION="8.6.10"

### Tcl (Tool Command Language)
# Скриптовый язык со множеством встроенных функций, которые делают его очень
# удобным для написания интерактивных сценариев.

# http://www.linuxfromscratch.org/blfs/view/stable/general/tcl.html

# Home page: http://www.tcl.tk/
# Download:  https://downloads.sourceforge.net/tcl/tcl8.6.10-src.tar.gz
#            https://downloads.sourceforge.net/tcl/tcl8.6.10-html.tar.gz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="/root/src"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}${VERSION}"-src.tar.?z*
cd "${PRGNAME}${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

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

VER="$(echo "${VERSION}" | cut -d . -f 1,2)"
TDBC_VER="1.1.1"
ITCL_VER="4.2.0"
sed -e "s#$SRCDIR/unix/pkgs/tdbc${TDBC_VER}#/usr/lib/tdbc${TDBC_VER}#" \
    -e "s#$SRCDIR/pkgs/tdbc${TDBC_VER}/generic#/usr/include#"    \
    -e "s#$SRCDIR/pkgs/tdbc${TDBC_VER}/library#/usr/lib/tcl$VER#" \
    -e "s#$SRCDIR/pkgs/tdbc${TDBC_VER}#/usr/include#"            \
    -i pkgs/tdbc${TDBC_VER}/tdbcConfig.sh || exit 1

sed -e "s#$SRCDIR/unix/pkgs/itcl${ITCL_VER}#/usr/lib/itcl${ITCL_VER}#" \
    -e "s#$SRCDIR/pkgs/itcl${ITCL_VER}/generic#/usr/include#"    \
    -e "s#$SRCDIR/pkgs/itcl${ITCL_VER}#/usr/include#"            \
    -i pkgs/itcl${ITCL_VER}/itclConfig.sh || exit 1

# make test
make install
make install DESTDIR="${TMP_DIR}"
make install-private-headers
make install-private-headers DESTDIR="${TMP_DIR}"

# ссылка в /usr/bin/ tclsh -> tclsh${VER}
ln -svf "tclsh${VER}" /usr/bin/tclsh
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -svf "tclsh${VER}" tclsh
)
chmod -v 755 "/usr/lib/libtcl${VER}.so"
chmod -v 755 "${TMP_DIR}/usr/lib/libtcl${VER}.so"

# документация
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${DOCS}"
mkdir -pv "${TMP_DIR}${DOCS}"
tar xvf "${SOURCES}/${PRGNAME}${VERSION}-html.tar".?z* --strip-components=1

cp -vR html/* "${DOCS}"
cp -vR html/* "${TMP_DIR}${DOCS}"

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

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
