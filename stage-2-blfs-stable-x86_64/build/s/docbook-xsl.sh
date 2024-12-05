#! /bin/bash

PRGNAME="docbook-xsl"
ARCH_NAME="${PRGNAME}-nons"

### docbook-xsl (Stylesheets package)
# Таблицы стилей XSL, которые нужны для выполнения преобразований в файлах XML
# DocBook

# Required:    libxml2
# Recommended: no
# Optional:    apache-ant       (для сборки "webhelp" документации)
#              libxslt
#              python2          (https://www.python.org/downloads/release/python-2718/)
#              ruby             (для использования таблиц стилей "epub")
#              zip              (для сборки "epub3" документации)
#              saxon6           (используется вместе с apache-ant) https://sourceforge.net/projects/saxon/files/saxon6/
#              xerces2-java     (используется вместе с apache-ant) http://xerces.apache.org/xerces2-j/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
XSL_STYLESHEETS="/usr/share/xml/docbook/xsl-stylesheets-nons-${VERSION}"
mkdir -pv "${TMP_DIR}"{"${XSL_STYLESHEETS}","${DOCS}"}

# исправим проблему переполнения стека при выполнении рекурсии
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-stack_fix-1.patch" || exit 1

cp -vR VERSION assembly common eclipse epub epub3 extensions fo        \
       highlighting html htmlhelp images javahelp lib manpages params  \
       profiling roundtrip slides template tests tools webhelp website \
       xhtml xhtml-1_1 xhtml5 "${TMP_DIR}${XSL_STYLESHEETS}"

(
    cd "${TMP_DIR}${XSL_STYLESHEETS}" || exit 1
    ln -s VERSION VERSION.xsl
)

install -v -m644 README RELEASE-NOTES* NEWS* "${TMP_DIR}${DOCS}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# удалим старые записи в /etc/xml/catalog
# (файл устанавливается с пакетом docbook-xml)
XML_CATALOG="/etc/xml/catalog"
sed -i '/rewrite/d' "${XML_CATALOG}" || exit 1

xmlcatalog --noout --add "rewriteSystem" \
        "https://cdn.docbook.org/release/xsl-nons/${VERSION}" \
        "${XSL_STYLESHEETS}" "${XML_CATALOG}" &&
xmlcatalog --noout --add "rewriteURI" \
        "https://cdn.docbook.org/release/xsl-nons/${VERSION}" \
        "${XSL_STYLESHEETS}" "${XML_CATALOG}" &&
xmlcatalog --noout --add "rewriteSystem" \
        "https://cdn.docbook.org/release/xsl-nons/current" \
        "${XSL_STYLESHEETS}" "${XML_CATALOG}" &&
xmlcatalog --noout --add "rewriteURI" \
        "https://cdn.docbook.org/release/xsl-nons/current" \
        "${XSL_STYLESHEETS}" "${XML_CATALOG}" &&
xmlcatalog --noout --add "rewriteSystem" \
        "http://docbook.sourceforge.net/release/xsl/current" \
        "${XSL_STYLESHEETS}" "${XML_CATALOG}" &&
xmlcatalog --noout --add "rewriteURI" \
        "http://docbook.sourceforge.net/release/xsl/current" \
        "${XSL_STYLESHEETS}" "${XML_CATALOG}"

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
