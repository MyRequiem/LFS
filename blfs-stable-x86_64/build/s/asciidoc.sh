#! /bin/bash

PRGNAME="asciidoc"

### AsciiDoc (a text document format)
# Текстовый формат документов для написания заметок, документация, статей,
# книг, слайд-шоу, веб-страниц, man-страниц и блогов. Файлы AsciiDoc могут быть
# переведены во многие форматы, включая HTML, PDF, EPUB и man-страницы.

# http://www.linuxfromscratch.org/blfs/view/stable/general/asciidoc.html

# Home page: http://asciidoc.org/
# Download:  https://downloads.sourceforge.net/asciidoc/asciidoc-8.6.9.tar.gz

# Required: python2
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не содержит набора тестов

make install
make install DESTDIR="${TMP_DIR}"

make docs
make docs DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a text document format)
#
# The Asciidoc package is a text document format for writing notes,
# documentation, articles, books, ebooks, slideshows, web pages, man pages and
# blogs. AsciiDoc files can be translated to many formats including HTML, PDF,
# EPUB, and man page.
#
# Home page: http://asciidoc.org/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
