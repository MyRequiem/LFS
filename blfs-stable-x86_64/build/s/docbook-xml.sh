#! /bin/bash

PRGNAME="docbook-xml"
VERSION="4.5"

### docbook-xml
# Пакет содержит определения типов документов для проверки файлов данных XML по
# набору правил DocBook. Применяется для структурирования книг и документации
# программного обеспечения в соответствии со стандартом.

# http://www.linuxfromscratch.org/blfs/view/9.0/pst/docbook.html
# Home page: http://www.docbook.org/xml/
# Download:  http://www.docbook.org/xml/4.5/docbook-xml-4.5.zip

# Required: libxml2
#           sgml-common
#           unzip
# Optional: no

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

SOURCES="/sources"
BUILD_DIR="${SOURCES}/build"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
rm -rf "${PRGNAME}-${VERSION}"

unzip -d "${PRGNAME}-${VERSION}" "${SOURCES}/"${PRGNAME}-${VERSION}".zip"
cd "${PRGNAME}-${VERSION}" || exit 1
chown -R root:root .

install -v -d -m755 "/usr/share/xml/docbook/xml-dtd-${VERSION}"
install -v -d -m755 "${TMP_DIR}/usr/share/xml/docbook/xml-dtd-${VERSION}"
install -v -d -m755 /etc/xml
install -v -d -m755 "${TMP_DIR}/etc/xml"

cp -v -af docbook.cat ./*.dtd ent/ ./*.mod \
    "/usr/share/xml/docbook/xml-dtd-${VERSION}"
cp -v -af docbook.cat ./*.dtd ent/ ./*.mod \
    "${TMP_DIR}/usr/share/xml/docbook/xml-dtd-${VERSION}"

if [ ! -e /etc/xml/docbook ]; then
    xmlcatalog --noout --create /etc/xml/docbook
fi

xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML V4.5//EN" \
    "http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD DocBook XML CALS Table Model V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/calstblx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//DTD XML Exchange Table Model 19990315//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/soextblx.dtd" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Information Pool V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbpoolx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML Document Hierarchy V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbhierx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ELEMENTS DocBook XML HTML Tables V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/htmltblx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Notations V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbnotnx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Character Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbcentx.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "public" \
    "-//OASIS//ENTITIES DocBook XML Additional General Entities V4.5//EN" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5/dbgenent.mod" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "rewriteSystem" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook &&
xmlcatalog --noout --add "rewriteURI" \
    "http://www.oasis-open.org/docbook/xml/4.5" \
    "file:///usr/share/xml/docbook/xml-dtd-4.5" \
    /etc/xml/docbook

if [ ! -e /etc/xml/catalog ]; then
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

mkdir -pv "${TMP_DIR}/etc/xml"
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
# Download:  http://www.docbook.org/xml/${VERSION}/${PRGNAME}-${VERSION}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
