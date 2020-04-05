#! /bin/bash

PRGNAME="docbook-xsl-nons"

### docbook-xsl-nons
# Таблицы стилей XSL которые нужны для выполнения преобразований в файлах
# XML DocBook

# http://www.linuxfromscratch.org/blfs/view/9.0/pst/docbook-xsl.html

# Home page: https://github.com/docbook/xslt10-stylesheets/
# Download:  https://github.com/docbook/xslt10-stylesheets/releases/download/release/1.79.2/docbook-xsl-nons-1.79.2.tar.bz2
# Patch:     http://www.linuxfromscratch.org/patches/blfs/9.0/docbook-xsl-nons-1.79.2-stack_fix-1.patch
# Docs:      https://github.com/docbook/xslt10-stylesheets/releases/download/release/1.79.2/docbook-xsl-doc-1.79.2.tar.bz2

# Required: no
# Recommended: libxml2
# Optional:    apache-ant
#              libxslt
#              python2
#              ruby
#              zip

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим проблему переполнения стека при выполнении рекурсии
patch -Np1 -i /sources/docbook-xsl-nons-1.79.2-stack_fix-1.patch
# документация
tar -xf /sources/docbook-xsl-doc-1.79.2.tar.bz2 --strip-components=1

install -v -m755 -d \
    "/usr/share/xml/docbook/xsl-stylesheets-nons-${VERSION}"
install -v -m755 -d \
    "${TMP_DIR}/usr/share/xml/docbook/xsl-stylesheets-nons-${VERSION}"

cp -vR   VERSION assembly common eclipse epub epub3 extensions fo        \
         highlighting html htmlhelp images javahelp lib manpages params  \
         profiling roundtrip slides template tests tools webhelp website \
         xhtml xhtml-1_1 xhtml5                                          \
        "/usr/share/xml/docbook/xsl-stylesheets-nons-${VERSION}"
cp -vR   VERSION assembly common eclipse epub epub3 extensions fo        \
         highlighting html htmlhelp images javahelp lib manpages params  \
         profiling roundtrip slides template tests tools webhelp website \
         xhtml xhtml-1_1 xhtml5                                          \
        "${TMP_DIR}/usr/share/xml/docbook/xsl-stylesheets-nons-${VERSION}"

ln -s VERSION \
    "/usr/share/xml/docbook/xsl-stylesheets-nons-${VERSION}/VERSION.xsl"
(
    cd "${TMP_DIR}/usr/share/xml/docbook/xsl-stylesheets-nons-${VERSION}" || \
        exit 1
    ln -s VERSION VERSION.xsl
)

install -v -m644 -D README \
    "/usr/share/doc/docbook-xsl-nons-${VERSION}/README.txt"
install -v -m644 -D README \
    "${TMP_DIR}/usr/share/doc/docbook-xsl-nons-${VERSION}/README.txt"

install -v -m644 RELEASE-NOTES* NEWS* \
    "/usr/share/doc/docbook-xsl-nons-${VERSION}"
install -v -m644 RELEASE-NOTES* NEWS* \
    "${TMP_DIR}/usr/share/doc/docbook-xsl-nons-${VERSION}"

cp -vR doc/* "/usr/share/doc/docbook-xsl-nons-${VERSION}"
cp -vR doc/* "${TMP_DIR}/usr/share/doc/docbook-xsl-nons-${VERSION}"

! [ -d /etc/xml ] && install -v -m755 -d /etc/xml
install -v -m755 -d "${TMP_DIR}/etc/xml"

! [ -f /etc/xml/catalog ] && xmlcatalog --noout --create /etc/xml/catalog

xmlcatalog --noout --add "rewriteSystem" \
           "https://cdn.docbook.org/release/xsl-nons/1.79.2" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteURI" \
           "https://cdn.docbook.org/release/xsl-nons/1.79.2" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteSystem" \
           "https://cdn.docbook.org/release/xsl-nons/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteURI" \
           "https://cdn.docbook.org/release/xsl-nons/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteSystem" \
           "http://docbook.sourceforge.net/release/xsl/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog &&
xmlcatalog --noout --add "rewriteURI" \
           "http://docbook.sourceforge.net/release/xsl/current" \
           "/usr/share/xml/docbook/xsl-stylesheets-nons-1.79.2" \
            /etc/xml/catalog

cp /etc/xml/catalog "${TMP_DIR}/etc/xml/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Stylesheets package)
#
# The DocBook XSL Stylesheets package contains XSL stylesheets. These are
# useful for performing transformations on XML DocBook files.
#
# Home page: https://github.com/docbook/xslt10-stylesheets/
# Download:  https://github.com/docbook/xslt10-stylesheets/releases/download/release/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
# Docs:      https://github.com/docbook/xslt10-stylesheets/releases/download/release/${VERSION}/docbook-xsl-doc-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
