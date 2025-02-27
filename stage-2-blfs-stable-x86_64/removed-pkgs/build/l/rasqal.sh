#! /bin/bash

PRGNAME="rasqal"

### Rasqal (RDF parsing library)
# Библиотека, обеспечивающая обработку/выполнение запросов к Resource
# Description Framework (RDF) и возврат результатов. В настоящее время
# поддерживается язык запросов к данным RDF (RDQL) и SPARQL

# Required:    raptor
# Recommended: no
# Optional:    libgcrypt

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
# Package: ${PRGNAME} (RDF parsing library)
#
# Rasqal is a library providing full support for querying Resource Description
# Framework (RDF) including parsing query syntaxes, constructing the queries,
# executing them and returning result formats. It currently handles the RDF
# Data Query Language (RDQL) and SPARQL Query language.
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
