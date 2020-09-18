#! /bin/bash

PRGNAME="rasqal"

### Rasqal (Resource Description Framework (RDF) Query Library)
# C-библиотека (RDF Query Library) для выполнения запросов RDF (Resource
# Description Framework) с использованием RDQL и SPARQL

# http://www.linuxfromscratch.org/blfs/view/stable/general/rasqal.html

# Home page: http://librdf.org/
# Download:  http://download.librdf.org/source/rasqal-0.9.33.tar.gz

# Required: raptor
# Optional: pcre
#           libgcrypt

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
# Package: ${PRGNAME} (Resource Description Framework (RDF) Query Library)
#
# Rasqal is a free software/Open Source C library that handles Resource
# Description Framework (RDF) query language syntaxes, query construction and
# execution of queries returning results as bindings, boolean, RDF
# graphs/triples or syntaxes. The supported query languages are SPARQL Query
# 1.0, SPARQL Query 1.1, SPARQL Update 1.1 (no executing) and the Experimental
# SPARQL extensions (LAQRS). Rasqal can write binding query results in the
# SPARQL XML, SPARQL JSON, CSV, TSV, HTML, ASCII tables, RDF/XML and Turtle /
# N3 and read them in SPARQL XML, CSV, TSV, RDF/XML and Turtle / N3.
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
