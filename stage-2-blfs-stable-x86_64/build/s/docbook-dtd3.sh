#! /bin/bash

PRGNAME="docbook-dtd3"
ARCH_NAME="docbk31"
VERSION="3.1"

### docbook-3.1-dtd (document type definitions for verification of SGML data)
# Определения типов документов для проверки файлов данных SGML на соответствие
# набору правил DocBook. Применяется для структурирования книг и документации
# программного обеспечения в соответствии с DocBook стандартом.

# Required:    sgml-common
#              unzip
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

unzip -d "${PRGNAME}-${VERSION}" "${SOURCES}/${ARCH_NAME}.zip" || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
SHARE_SGML="/usr/share/sgml/docbook/sgml-dtd-${VERSION}"
mkdir -pv "${TMP_DIR}"{/etc/sgml,"${SHARE_SGML}"}

chown -R root:root .

sed -e '/ISO 8879/d'                                           \
    -e 's|DTDDECL "-//OASIS//DTD DocBook V3.1//EN"|SGMLDECL|g' \
    -i docbook.cat

install -v -d -m755       "${SHARE_SGML}"
cp -avf ./*.{dtd,mod,dcl} "${SHARE_SGML}/"
install -v docbook.cat    "${SHARE_SGML}/catalog"
chmod 644 "${SHARE_SGML}/catalog"

ETC_SGML_CAT="/etc/sgml/sgml-docbook-dtd-${VERSION}.cat"
install-catalog --add "${ETC_SGML_CAT}" "${SHARE_SGML}/catalog"
install-catalog --add "${ETC_SGML_CAT}" /etc/sgml/sgml-docbook.cat

cat << EOF >> "${SHARE_SGML}/catalog"

  -- Begin Single Major Version catalog changes --

PUBLIC "-//Davenport//DTD DocBook V3.0//EN" "docbook.dtd"

  -- End Single Major Version catalog changes --
EOF

cp "${SHARE_SGML}"/* "${TMP_DIR}${SHARE_SGML}/"
cp "${ETC_SGML_CAT}" "${TMP_DIR}${ETC_SGML_CAT}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (document type definitions for verification of SGML data)
#
# The DocBook SGML DTD package contains document type definitions for
# verification of SGML data files against the DocBook rule set. These are
# useful for structuring books and software documentation to a standard
# allowing you to utilize transformations already written for that standard.
#
# Home page: https://docbook.org/
# Download:  http://www.docbook.org/sgml/${VERSION}/${ARCH_NAME}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
