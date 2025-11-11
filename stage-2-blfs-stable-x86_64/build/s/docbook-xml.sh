#! /bin/bash

PRGNAME="docbook-xml"

### docbook-xml (document type definitions)
# Пакет содержит определения типов документов для проверки файлов данных XML по
# набору правил DocBook. Применяется для структурирования книг и документации
# программного обеспечения в соответствии со стандартом.

# Required:    libarchive  (для распаковки архива с исходниками)
#              libxml2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
XML_DTD="/usr/share/xml/docbook/xml-dtd-${VERSION}"
mkdir -pv "${TMP_DIR}"{/etc/xml,"${XML_DTD}"}

cp -v -af --no-preserve=ownership docbook.cat *.dtd ent/ *.mod \
    "${TMP_DIR}${XML_DTD}"

XML_DOCBOOK="/etc/xml/docbook"
xmlcatalog --noout --create "${TMP_DIR}${XML_DOCBOOK}"

xmlcatalog --noout --add "public"                            \
    "-//OASIS//DTD DocBook XML V4.5//EN"                     \
    "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "public"                            \
    "-//OASIS//DTD DocBook XML CALS Table Model V4.5//EN"    \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/calstblx.dtd" \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "public"                            \
    "-//OASIS//DTD XML Exchange Table Model 19990315//EN"    \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/soextblx.dtd" \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "public"                              \
    "-//OASIS//ELEMENTS DocBook XML Information Pool V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbpoolx.mod"    \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "public"                                \
    "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbhierx.mod"      \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "public"                            \
    "-//OASIS//ELEMENTS DocBook XML HTML Tables V4.5//EN"    \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/htmltblx.mod" \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "public"                           \
    "-//OASIS//ENTITIES DocBook XML Notations V4.5//EN"     \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbnotnx.mod" \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "public"                                \
    "-//OASIS//ENTITIES DocBook XML Character Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbcentx.mod"      \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "public"                                         \
    "-//OASIS//ENTITIES DocBook XML Additional General Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbgenent.mod"              \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "rewriteSystem"        \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    "${TMP_DIR}${XML_DOCBOOK}" &&

xmlcatalog --noout --add "rewriteURI"           \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    "${TMP_DIR}${XML_DOCBOOK}"

### /etc/xml/catalog
xmlcatalog --noout --create "${TMP_DIR}/etc/xml/catalog"

xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//ENTITIES DocBook XML"      \
    "file:///etc/xml/docbook"             \
    "${TMP_DIR}/etc/xml/catalog" &&

xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//DTD DocBook XML"           \
    "file:///etc/xml/docbook"             \
    "${TMP_DIR}/etc/xml/catalog" &&

xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/"  \
    "file:///etc/xml/docbook"             \
    "${TMP_DIR}/etc/xml/catalog" &&

xmlcatalog --noout --add "delegateURI"    \
    "http://www.oasis-open.org/docbook/"  \
    "file:///etc/xml/docbook"             \
    "${TMP_DIR}/etc/xml/catalog"

# будем использовать docbook-xml-${VERSION} при запросе любой версии 4.x
# (4.1.2, 4.2, 4.3, 4.4)
for DTDVERSION in 4.1.2 4.2 4.3 4.4; do
    xmlcatalog --noout --add "public" \
        "-//OASIS//DTD DocBook XML V${DTDVERSION}//EN" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}/docbookx.dtd" \
        "${TMP_DIR}/etc/xml/docbook"
    xmlcatalog --noout --add "rewriteSystem" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}" \
        "file:///usr/share/xml/docbook/xml-dtd-${VERSION}" \
        "${TMP_DIR}/etc/xml/docbook"
    xmlcatalog --noout --add "rewriteURI" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}" \
        "file:///usr/share/xml/docbook/xml-dtd-${VERSION}" \
        "${TMP_DIR}/etc/xml/docbook"
    xmlcatalog --noout --add "delegateSystem" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}/" \
        "file:///etc/xml/docbook" \
        "${TMP_DIR}/etc/xml/catalog"
    xmlcatalog --noout --add "delegateURI" \
        "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
        "file:///etc/xml/docbook" \
        "${TMP_DIR}/etc/xml/catalog"
done

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (document type definitions)
#
# The DocBook XML DTD-4.5 package contains document type definitions for
# verification of XML data files against the DocBook rule set. These are useful
# for structuring books and software documentation to a standard allowing you
# to utilize transformations already written for that standard.
#
# Home page: https://www.docbook.org/
# Download:  https://www.docbook.org/xml/${VERSION}/${PRGNAME}-${VERSION}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
