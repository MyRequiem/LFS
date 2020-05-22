#! /bin/bash

PRGNAME="docbook-xml"

### docbook-xml (document type definitions)
# Пакет содержит определения типов документов для проверки файлов данных XML по
# набору правил DocBook. Применяется для структурирования книг и документации
# программного обеспечения в соответствии со стандартом.

# http://www.linuxfromscratch.org/blfs/view/stable/pst/docbook.html

# Home page: http://www.docbook.org/xml/
# Download:  https://www.oasis-open.org/docbook/xml/4.5/docbook-xml-4.5.zip

# Required: libxml2
#           sgml-common
#           unzip (для распаковки архива с исходниками)
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/{etc/xml,"usr/share/xml/docbook/xml-dtd-${VERSION}"}

XML_DTD="/usr/share/xml/docbook/xml-dtd-${VERSION}"
install -v -d -m755 "${XML_DTD}"
install -v -d -m755 /etc/xml

cp -v -af docbook.cat ./*.dtd ent/ ./*.mod "${XML_DTD}"
cp -v -af docbook.cat ./*.dtd ent/ ./*.mod "${TMP_DIR}${XML_DTD}"

if ! [ -e /etc/xml/docbook ]; then
    xmlcatalog --noout --create /etc/xml/docbook
fi

xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V${VERSION}//EN" \
    "http://www.oasis-open.org/docbook/xml/${VERSION}/docbookx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML CALS Table Model V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/calstblx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD XML Exchange Table Model 19990315//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/soextblx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Information Pool V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbpoolx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbhierx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML HTML Tables V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/htmltblx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Notations V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbnotnx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Character Entities V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbcentx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Additional General Entities V${VERSION}//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}/dbgenent.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/${VERSION}" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/${VERSION}" \
    "file:///usr/share/xml/docbook/xml-dtd-${VERSION}" \
    /etc/xml/docbook

if ! [ -e /etc/xml/catalog ]; then
    xmlcatalog --noout --create /etc/xml/catalog
fi

xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//ENTITIES DocBook XML" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegatePublic" \
    "-//OASIS//DTD DocBook XML" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegateSystem" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog &&
xmlcatalog --noout --add "delegateURI" \
    "http://www.oasis-open.org/docbook/" \
    "file:///etc/xml/docbook" \
    /etc/xml/catalog

# будем использовать docbook-xml-${VERSION} при запросе любой версии 4.x
# (4.1.2, 4.2, 4.3, 4.4)
for DTDVERSION in 4.1.2 4.2 4.3 4.4; do
    xmlcatalog --noout --add "public" \
        "-//OASIS//DTD DocBook XML V${DTDVERSION}//EN" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}/docbookx.dtd" \
        /etc/xml/docbook
    xmlcatalog --noout --add "rewriteSystem" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}" \
        "file:///usr/share/xml/docbook/xml-dtd-${VERSION}" \
        /etc/xml/docbook
    xmlcatalog --noout --add "rewriteURI" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}" \
        "file:///usr/share/xml/docbook/xml-dtd-${VERSION}" \
        /etc/xml/docbook
    xmlcatalog --noout --add "delegateSystem" \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}/" \
        "file:///etc/xml/docbook" \
        /etc/xml/catalog
    xmlcatalog --noout --add "delegateURI" \
        "http://www.oasis-open.org/docbook/xml/$DTDVERSION/" \
        "file:///etc/xml/docbook" \
        /etc/xml/catalog
done

cp -vR /etc/xml/* "${TMP_DIR}/etc/xml/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (document type definitions)
#
# The DocBook XML DTD-4.5 package contains document type definitions for
# verification of XML data files against the DocBook rule set. These are useful
# for structuring books and software documentation to a standard allowing you
# to utilize transformations already written for that standard.
#
# Home page: http://www.docbook.org/xml/
# Download:  https://www.oasis-open.org/docbook/xml/${VERSION}/${PRGNAME}-${VERSION}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
