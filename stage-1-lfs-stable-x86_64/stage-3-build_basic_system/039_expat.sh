#! /bin/bash

PRGNAME="expat"

### Expat (C library for parsing XML)
# Пакет содержит потоково-ориентированную библиотеку C для анализа XML

# http://www.linuxfromscratch.org/lfs/view/stable/chapter06/expat.html

# Home page: https://libexpat.github.io/
# Download:  https://prdownloads.sourceforge.net/expat/expat-2.2.9.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим проблему с регрессионными тестами в среде LFS
sed -i 's|usr/bin/env |bin/|' run.sh.in || exit 1

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="${DOCS}" || exit 1

make || exit 1
make check
make install
make install DESTDIR="${TMP_DIR}"

# установим документацию
install -v -m644 doc/*.{html,png,css} "${DOCS}"
mkdir -pv "${TMP_DIR}${DOCS}"
install -v -m644 doc/*.{html,png,css} "${TMP_DIR}${DOCS}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C library for parsing XML)
#
# This is Expat, a C library for parsing XML. Expat is a stream-oriented XML
# parser used by Python, GNOME, Xft2, and other things.
#
# Home page: https://libexpat.github.io/
# Download:  https://prdownloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
