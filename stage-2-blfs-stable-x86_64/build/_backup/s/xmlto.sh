#! /bin/bash

PRGNAME="xmlto"

### xmlto (front-end to a XSL toolchain)
# Внешний интерфейс для цепочки инструментов XSL. Выбирает соответствующую
# таблицу стилей для преобразования и применяет ее, используя внешний
# XSLT-процессор. Также выполняет любую необходимую последующую обработку.

# http://www.linuxfromscratch.org/blfs/view/stable/pst/xmlto.html

# Home page: https://pagure.io/xmlto
# Download:  https://releases.pagure.org/xmlto/xmlto-0.0.28.tar.bz2

# Required: docbook-xml
#           docbook-xsl
#           libxslt
# Optional: fop
#           dblatex https://sourceforge.net/projects/dblatex/files/dblatex/
#           passivetex http://www.garshol.priv.no/download/xmltools/prod/PassiveTeX.html
#           links или lynx или w3m (http://w3m.sourceforge.net/) или elinks (http://elinks.or.cz/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# xmlto думает что команда links тоже самое что и команда elinks, исправим это
# установив переменную LINKS
LINKS="/usr/bin/links" \
./configure            \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (front-end to a XSL toolchain)
#
# The xmlto package is a front-end to a XSL toolchain. It chooses an
# appropriate stylesheet for the conversion you want and applies it using an
# external XSLT processor. It also performs any necessary post-processing.
#
# Home page: https://pagure.io/${PRGNAME}
# Download:  https://releases.pagure.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
