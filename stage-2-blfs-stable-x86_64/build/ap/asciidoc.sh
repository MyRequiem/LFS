#! /bin/bash

PRGNAME="asciidoc"

### AsciiDoc (a text document format)
# Текстовый формат документов для написания заметок, документация, статей,
# книг, слайд-шоу, веб-страниц, man-страниц и блогов. Файлы AsciiDoc могут быть
# переведены во многие форматы, включая HTML, PDF, EPUB и man-страницы.

# Required:    no
# Recommended: no
# Optional:    docbook-xsl
#              fop
#              libxslt
#              lynx
#              dblatex (https://sourceforge.net/projects/dblatex/)
#              w3m     (http://w3m.sourceforge.net/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# устраним проблему сборки, если не установлены опциональные зависимости
sed -i 's:doc/testasciidoc.1::' Makefile.in || exit 1
rm -f doc/testasciidoc.1.txt

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"
make docs    DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a text document format)
#
# The Asciidoc package is a text document format for writing notes,
# documentation, articles, books, ebooks, slideshows, web pages, man pages and
# blogs. AsciiDoc files can be translated to many formats including HTML, PDF,
# EPUB, and man page.
#
# Home page: http://asciidoc.org/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}-py3/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
