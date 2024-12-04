#! /bin/bash

PRGNAME="redland"

### Redland (RDF high-level interface library)
# Библиотека, которая предоставляет высокоуровневый интерфейс для Resource
# Description Framework (RDF)

# Required:    rasqal
# Recommended: no
# Optional:    sqlite
#              mariadb или mysql (https://www.mysql.com/)
#              postgresql
#              berkeley-db       (https://www.oracle.com/database/technologies/related/berkeleydb.html)
#              libiodbc          (https://sourceforge.net/projects/iodbc/files/)
#              virtuoso          (https://downloads.sourceforge.net/virtuoso/)
#              3store            (https://sourceforge.net/projects/threestore/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

INSTALL_GTK_DOC="false"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${INSTALL_GTK_DOC}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (RDF high-level interface library)
#
# Redland is a library that provides a high-level interface for the Resource
# Description Framework (RDF) allowing the RDF graph to be parsed from XML,
# stored, queried and manipulated. Redland implements each of the RDF concepts
# in its own class via an object based API, reflected into the language APIs,
# currently C#, Java, Perl, PHP, Python, Ruby and Tcl.
#
# Home page: https://librdf.org/
# Download:  https://download.librdf.org/source/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
