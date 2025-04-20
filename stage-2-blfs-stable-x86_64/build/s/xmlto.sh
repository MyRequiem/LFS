#! /bin/bash

PRGNAME="xmlto"

### xmlto (front-end to a XSL toolchain)
# Внешний интерфейс для цепочки инструментов XSL. Выбирает соответствующую
# таблицу стилей для преобразования и применяет ее, используя внешний
# XSLT-процессор. Также выполняет любую необходимую последующую обработку.

# Required:    docbook-xml
#              docbook-xsl
#              libxslt
# Recommended: no
# Optional:    --- для dvi, pdf и postscript backend ---
#              fop
#              dblatex      (https://sourceforge.net/projects/dblatex/files/dblatex/)
#              passivetex   (https://www.garshol.priv.no/download/xmltools/prod/PassiveTeX.html)
#              --- для text backend один из консольных браузеров ---
#              links
#              lynx
#              w3m          (http://w3m.sourceforge.net/)
#              elinks       (http://elinks.or.cz/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

autoreconf -fiv || exit 1
LINKS="/usr/bin/w3m" \
./configure            \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (front-end to a XSL toolchain)
#
# The xmlto package is a front-end to a XSL toolchain. It chooses an
# appropriate stylesheet for the conversion you want and applies it using an
# external XSLT processor. It also performs any necessary post-processing.
#
# Home page: https://pagure.io/${PRGNAME}
# Download:  https://pagure.io/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
