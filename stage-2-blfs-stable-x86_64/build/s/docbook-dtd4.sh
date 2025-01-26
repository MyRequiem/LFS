#! /bin/bash

PRGNAME="docbook-dtd4"
ARCH_NAME="docbook"

### docbook-4.5-dtd (document type definitions for verification of SGML data)
# Определения типов документов для проверки файлов данных SGML на соответствие
# набору правил DocBook. Применяется для структурирования книг и документации
# программного обеспечения в соответствии с DocBook стандартом.

# Required:    sgml-common
#              unzip или libarchive
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-4*.zip" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 2- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

unzip -d "${ARCH_NAME}-${VERSION}" \
    "${SOURCES}/${ARCH_NAME}-${VERSION}".zip || exit 1

cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
SHARE_SGML="/usr/share/sgml/docbook/sgml-dtd-${VERSION}"
mkdir -pv "${TMP_DIR}"{/etc/sgml,"${SHARE_SGML}"}

sed -i -e '/ISO 8879/d' \
       -e '/gml/d'      \
       docbook.cat || exit 1

install -v -d -m755             "${SHARE_SGML}"
cp -avf ./*.dtd ./*.mod ./*.dcl "${SHARE_SGML}/"
install -v docbook.cat          "${SHARE_SGML}/catalog"
chmod 644 "${SHARE_SGML}/catalog"

ETC_SGML_CAT="/etc/sgml/sgml-docbook-dtd-${VERSION}.cat"
install-catalog --add "${ETC_SGML_CAT}" "${SHARE_SGML}/catalog"
install-catalog --add "${ETC_SGML_CAT}" /etc/sgml/sgml-docbook.cat

cat << EOF >> "${SHARE_SGML}/catalog"
  -- Begin Single Major Version catalog changes --

PUBLIC "-//OASIS//DTD DocBook V4.4//EN" "docbook.dtd"
PUBLIC "-//OASIS//DTD DocBook V4.3//EN" "docbook.dtd"
PUBLIC "-//OASIS//DTD DocBook V4.2//EN" "docbook.dtd"
PUBLIC "-//OASIS//DTD DocBook V4.1//EN" "docbook.dtd"
PUBLIC "-//OASIS//DTD DocBook V4.0//EN" "docbook.dtd"

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
# Home page: https://${ARCH_NAME}.org/
# Download:  http://www.${ARCH_NAME}.org/sgml/${VERSION}/${ARCH_NAME}-${VERSION}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
