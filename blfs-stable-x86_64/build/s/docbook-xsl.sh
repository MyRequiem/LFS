#! /bin/bash

PRGNAME="docbook-xsl"
ARCH_NAME="${PRGNAME}-nons"

### docbook-xsl
# Таблицы стилей XSL которые нужны для выполнения преобразований в файлах XML
# DocBook

# http://www.linuxfromscratch.org/blfs/view/stable/pst/docbook-xsl.html

# Home page: https://github.com/docbook/xslt10-stylesheets/
# Download:  https://github.com/docbook/xslt10-stylesheets/releases/download/release/1.79.2/docbook-xsl-nons-1.79.2.tar.bz2
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.1/docbook-xsl-nons-1.79.2-stack_fix-1.patch
# Docs:      https://github.com/docbook/xslt10-stylesheets/releases/download/release/1.79.2/docbook-xsl-doc-1.79.2.tar.bz2

# Required:    no
# Recommended: libxml2
# Optional:    apache-ant       (для сборки "webhelp" документации)
#              libxslt
#              python2-libxml2  (для сборки "docbook" документации)
#              python2          (runtime)
#              ruby             (для использования таблиц стилей "epub")
#              zip              (для сборки "epub3" документации)
#              saxon6           (используется вместе с apache-ant) https://sourceforge.net/projects/saxon/files/saxon6/
#              xerces2-java     (используется вместе с apache-ant) http://xerces.apache.org/xerces2-j/

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему переполнения стека при выполнении рекурсии
SOURCES="/root/src"
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-stack_fix-1.patch" || exit 1

# распакуем документацию
tar xvf \
    "${SOURCES}/${PRGNAME}-doc-${VERSION}.tar.bz2" --strip-components=1 || exit 1

XSL_STYLESHEETS="/usr/share/xml/docbook/xsl-stylesheets-${VERSION}"
install -v -m755 -d "${XSL_STYLESHEETS}"
install -v -m755 -d "${TMP_DIR}${XSL_STYLESHEETS}"

cp -vR   VERSION assembly common eclipse epub epub3 extensions fo        \
         highlighting html htmlhelp images javahelp lib manpages params  \
         profiling roundtrip slides template tests tools webhelp website \
         xhtml xhtml-1_1 xhtml5 "${XSL_STYLESHEETS}"
cp -vR   VERSION assembly common eclipse epub epub3 extensions fo        \
         highlighting html htmlhelp images javahelp lib manpages params  \
         profiling roundtrip slides template tests tools webhelp website \
         xhtml xhtml-1_1 xhtml5 "${TMP_DIR}${XSL_STYLESHEETS}"

ln -s VERSION "${XSL_STYLESHEETS}/VERSION.xsl"
(
    cd "${TMP_DIR}${XSL_STYLESHEETS}" || exit 1
    ln -s VERSION VERSION.xsl
)

DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
install -v -m644 -D README "${DOCS}/README.txt"
install -v -m644 -D README "${TMP_DIR}${DOCS}/README.txt"

install -v -m644 RELEASE-NOTES* NEWS* "${DOCS}"
install -v -m644 RELEASE-NOTES* NEWS* "${TMP_DIR}${DOCS}"

cp -vR doc/* "${DOCS}"
cp -vR doc/* "${TMP_DIR}${DOCS}"

# удалим старые записи в /etc/xml/catalog
sed -i '/rewrite/d' /etc/xml/catalog || exit 1

xmlcatalog --noout --add "rewriteSystem" \
           "https://cdn.docbook.org/release/xsl-nons/${VERSION}" \
           "${XSL_STYLESHEETS}" /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteURI" \
           "https://cdn.docbook.org/release/xsl-nons/${VERSION}" \
           "${XSL_STYLESHEETS}" /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteSystem" \
           "https://cdn.docbook.org/release/xsl-nons/current" \
           "${XSL_STYLESHEETS}" /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteURI" \
           "https://cdn.docbook.org/release/xsl-nons/current" \
           "${XSL_STYLESHEETS}" /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteSystem" \
           "http://docbook.sourceforge.net/release/xsl/current" \
           "${XSL_STYLESHEETS}" /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteURI" \
           "http://docbook.sourceforge.net/release/xsl/current" \
           "${XSL_STYLESHEETS}" /etc/xml/catalog

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Stylesheets package)
#
# The DocBook XSL Stylesheets package contains XSL stylesheets. These are
# useful for performing transformations on XML DocBook files.
#
# Home page: https://github.com/docbook/xslt10-stylesheets/
# Download:  https://github.com/docbook/xslt10-stylesheets/releases/download/release/${VERSION}/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
