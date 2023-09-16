#! /bin/bash

PRGNAME="docbook-dsssl"

### docbook-dsssl (DocBook DSSSL Stylesheets)
# DocBook DSSSL Stylesheets содержит таблицы стилей DSSSL, используемые
# OpenJade или другими инструментами для преобразования SGML и XML DocBook

# Required:    sgml-common
#              --- для тестирования набора инструментов DocBook SGML ---
#              docbook-dtd3
#              docbook-dtd4
#              opensp
#              openjade
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MANDIR="/usr/share/man/man1"
SHARE_SGML="/usr/share/sgml/docbook/dsssl-stylesheets-${VERSION}"
mkdir -pv "${TMP_DIR}"{/etc/sgml,/usr/bin,"${MANDIR}","${SHARE_SGML}"}

install -v -m755 bin/collateindex.pl   /usr/bin
install -v -m755 bin/collateindex.pl   "${TMP_DIR}/usr/bin"

install -v -m644 bin/collateindex.pl.1 "${MANDIR}"
install -v -m644 bin/collateindex.pl.1 "${TMP_DIR}${MANDIR}"

install -v -d -m755 "${SHARE_SGML}"
cp -vR ./*          "${SHARE_SGML}"

ETC_SGML_CAT="/etc/sgml/dsssl-docbook-stylesheets.cat"
install-catalog --add "${ETC_SGML_CAT}"          "${SHARE_SGML}/catalog"
install-catalog --add "${ETC_SGML_CAT}"          "${SHARE_SGML}/common/catalog"
install-catalog --add /etc/sgml/sgml-docbook.cat "${ETC_SGML_CAT}"

cp -R "${SHARE_SGML}"/* "${TMP_DIR}${SHARE_SGML}/"
cp "${ETC_SGML_CAT}" "${TMP_DIR}${ETC_SGML_CAT}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (DocBook DSSSL Stylesheets)
#
# The DocBook DSSSL Stylesheets package contains DSSSL stylesheets. These are
# used by OpenJade or other tools to transform SGML and XML DocBook files.
#
# Home page: https://docbook.sourceforge.net/
# Download:  https://downloads.sourceforge.net/docbook/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
