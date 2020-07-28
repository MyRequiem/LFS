#! /bin/bash

PRGNAME="redland"

### Redland (RDF high-level interface library)
# C-библиотеки, обеспечивающие интерфейс высокого уровня для описания ресурсов
# RDF (Resource Description Framework) в C#, Java, Perl, PHP, Python, Ruby и
# Tcl

# http://www.linuxfromscratch.org/blfs/view/stable/general/redland.html

# Home page: http://librdf.org/
# Download:  http://download.librdf.org/source/redland-1.0.17.tar.gz

# Required: rasqal
# Optional: berkeley-db
#           libiodbc
#           sqlite
#           mariadb или mysql (https://www.mysql.com/)
#           postgresql
#           virtuoso          (https://sourceforge.net/projects/virtuoso/files/)
#           3store            (https://sourceforge.net/projects/threestore/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (RDF high-level interface library)
#
# Redland is a library that provides a high-level interface for the Resource
# Description Framework (RDF) allowing the RDF graph to be parsed from XML,
# stored, queried and manipulated. Redland implements each of the RDF concepts
# in its own class via an object based API, reflected into the language APIs,
# currently C#, Java, Perl, PHP, Python, Ruby and Tcl.
#
# Home page: http://librdf.org/
# Download:  http://download.librdf.org/source/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
