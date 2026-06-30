#! /bin/bash

PRGNAME="docbook-xml"

### docbook-xml (document type definitions)
# Специальный набор правил и шаблонов, который позволяет писать сложные
# технические документы (книги, инструкции, справки) в едином формате XML. Он
# гарантирует, что структура вашего текста будет логичной и понятной для
# программ, которые потом превратят его в красивый PDF, веб или man-страницу.

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

# устанавливаем
# shellcheck disable=SC2035
cp -v -af --no-preserve=ownership \
    catalog.xml \
    docbook.cat \
    *.dtd       \
    ent/        \
    *.mod       \
    "${TMP_DIR}${XML_DTD}"

# поставляемый с пакетом catalog.xml обрабатывает формальные общедоступные
# идентификаторы XML DTD DocBook-${VERSION}. Нам нужно добавить еще несколько
# записей для обработки URL-адресов DTD
xmlcatalog --noout --add "rewriteSystem"               \
    "http://www.oasis-open.org/docbook/xml/${VERSION}" \
    "file://${XML_DTD}"                                \
    "${TMP_DIR}${XML_DTD}/catalog.xml" || exit 1

xmlcatalog --noout --add "rewriteURI"                  \
    "http://www.oasis-open.org/docbook/xml/${VERSION}" \
    "file://${XML_DTD}"                                \
    "${TMP_DIR}${XML_DTD}/catalog.xml" || exit 1

### /etc/xml/catalog
xmlcatalog --noout --create "${TMP_DIR}/etc/xml/catalog"

xmlcatalog --noout --add "delegatePublic"  \
    "-//OASIS//ENTITIES DocBook XML"       \
    "file://${XML_DTD}/catalog.xml"        \
    "${TMP_DIR}/etc/xml/catalog" || exit 1

xmlcatalog --noout --add "delegatePublic"  \
    "-//OASIS//DTD DocBook XML"            \
    "file://${XML_DTD}/catalog.xml"        \
    "${TMP_DIR}/etc/xml/catalog" || exit 1

xmlcatalog --noout --add "delegateSystem"  \
    "http://www.oasis-open.org/docbook/"   \
    "file://${XML_DTD}/catalog.xml" \
    "${TMP_DIR}/etc/xml/catalog" || exit 1

xmlcatalog --noout --add "delegateURI"     \
    "http://www.oasis-open.org/docbook/"   \
    "file://${XML_DTD}/catalog.xml" \
    "${TMP_DIR}/etc/xml/catalog" || exit 1

# будем использовать docbook-xml-${VERSION} при запросе любой версии 4.x
# (4.1.2, 4.2, 4.3, 4.4)
for DTDVERSION in 4.1.2 4.2 4.3 4.4; do
    xmlcatalog --noout --add "public"                                      \
        "-//OASIS//DTD DocBook XML V${DTDVERSION}//EN"                     \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}/docbookx.dtd" \
        "${TMP_DIR}${XML_DTD}/catalog.xml" || exit 1

    xmlcatalog --noout --add "rewriteSystem"                  \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}" \
        "file:///usr/share/xml/docbook/xml-dtd-4.5"           \
        "${TMP_DIR}${XML_DTD}/catalog.xml" || exit 1

    xmlcatalog --noout --add "rewriteURI"                     \
        "http://www.oasis-open.org/docbook/xml/${DTDVERSION}" \
        "file:///usr/share/xml/docbook/xml-dtd-4.5"           \
        "${TMP_DIR}${XML_DTD}/catalog.xml" || exit 1
done

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
# Download:  https://archive.docbook.org/xml/${VERSION}/${PRGNAME}-${VERSION}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
