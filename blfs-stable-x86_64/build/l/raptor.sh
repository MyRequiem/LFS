#! /bin/bash

PRGNAME="raptor"
ARCH_NAME="${PRGNAME}2"

### Raptor (Resource Description Framework (RDF) Parser & Serializer)
# C-библиотека, которая предоставляет набор синтаксических анализаторов и
# сериализаторов для генерации структур описания ресурсов (RDF).

# http://www.linuxfromscratch.org/blfs/view/stable/general/raptor.html

# Home page: http://librdf.org/
# Download:  http://download.librdf.org/source/raptor2-2.0.15.tar.gz

# Required: curl
#           libxslt
# Optional: gtk-doc
#           icu
#           libyajl (http://lloyd.github.io/yajl/)

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
ICU=""

command -v gtkdoc-mktmpl &>/dev/null && GTK_DOC="--enable-gtk-doc"
command -v icu-config   &>/dev/null && \
    ICU="--with-icu-config=/usr/bin/icu-config"

./configure       \
    --prefix=/usr \
    "${GTK_DOC}"  \
    ${ICU}        \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Resource Description Framework (RDF) Parser & Serializer)
#
# Raptor is a free software/Open Source C library that provides a set of
# parsers and serializers that generate Resource Description Framework (RDF)
# triples by parsing syntaxes or serialize the triples into a syntax. The
# supported parsing syntaxes are RDF/XML, N-Triples, TRiG, Turtle, RSS tag soup
# including all versions of RSS, Atom 1.0 and 0.3, GRDDL and microformats for
# HTML, XHTML and XML.
#
# Home page: http://librdf.org/
# Download:  http://download.librdf.org/source/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
