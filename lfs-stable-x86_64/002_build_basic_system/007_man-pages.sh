#! /bin/bash

PRGNAME="man-pages"

### Man-pages
# Пакет Man-pages содержит более 2300 man-страниц.
# Страницы устанавливаются в /usr/share/man/man{1,2,3,4,5,6,7,8}/*

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/man-pages.html

# Home page: https://www.kernel.org/doc/man-pages/
# Download:  https://www.kernel.org/pub/linux/docs/man-pages/man-pages-5.02.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (system documentation)
#
# Man pages are online documentation for Linux (contains over 2300 man pages).
# This package includes many section 1, 2, 3, 4, 5, 7, and 8 man pages for
# Linux.
#
# Home page: https://www.kernel.org/doc/${PRGNAME}/
# Download:  https://www.kernel.org/pub/linux/docs/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
