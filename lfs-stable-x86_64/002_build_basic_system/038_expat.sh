#! /bin/bash

PRGNAME="expat"

### Expat
# Пакет содержит потоково-ориентированную библиотеку C для анализа XML

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/expat.html

# Home page: https://libexpat.github.io/
# Download:  https://prdownloads.sourceforge.net/expat/expat-2.2.7.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# исправим проблему с регрессионными тестами в среде LFS
sed -i 's|usr/bin/env |bin/|' run.sh.in

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make check
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

# установим документацию
install -v -m644 doc/*.{html,png,css} \
    "/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -m644 doc/*.{html,png,css} \
    "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

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
