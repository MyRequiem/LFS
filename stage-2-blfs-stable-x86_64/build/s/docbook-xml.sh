#! /bin/bash

PRGNAME="docbook-xml"

### docbook-xml (document type definitions)
# Пакет содержит определения типов документов для проверки файлов данных XML по
# набору правил DocBook. Применяется для структурирования книг и документации
# программного обеспечения в соответствии со стандартом.

# Required:    libxml2
#              unzip или libarchive    (для распаковки архива с исходниками)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
XML_DTD="/usr/share/xml/docbook/xml-dtd-${VERSION}"
mkdir -pv "${TMP_DIR}"{/etc/xml,"${XML_DTD}"}

cp -vaf docbook.cat ./*.dtd ent/ ./*.mod "${TMP_DIR}${XML_DTD}"

### /etc/xml/docbook
xmlcatalog --noout --create "${TMP_DIR}/etc/xml/docbook"

xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V${VERSION}//EN" \
    "http://www.oasis-open.org/docbook/xml/${VERSION}/docbookx.dtd" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML CALS Table Model V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/calstblx.dtd" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD XML Exchange Table Model 19990315//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/soextblx.dtd" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Information Pool V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbpoolx.mod" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbhierx.mod" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML HTML Tables V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/htmltblx.mod" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Notations V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbnotnx.mod" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Character Entities V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbcentx.mod" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Additional General Entities V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbgenent.mod" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/${VERSION}" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}" \
    "${TMP_DIR}/etc/xml/docbook" &&
xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/${VERSION}" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}" \
    "${TMP_DIR}/etc/xml/docbook"

### /etc/xml/catalog
xmlcatalog --noout --create "${TMP_DIR}/etc/xml/catalog"

xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//ENTITIES DocBook XML" \
    "file:///etc/xml/docbook" \
    "${TMP_DIR}/etc/xml/catalog" &&
xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//DTD DocBook XML" \
    "file:///etc/xml/docbook" \
    "${TMP_DIR}/etc/xml/catalog" &&
xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    "${TMP_DIR}/etc/xml/catalog" &&
xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
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
