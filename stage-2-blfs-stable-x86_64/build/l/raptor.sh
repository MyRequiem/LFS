#! /bin/bash

PRGNAME="raptor"
ARCH_NAME="${PRGNAME}2"

### Raptor (RDF Parser & Serializer)
# C-библиотека, которая предоставляет набор парсеров и сериализаторов для
# генерации Resource Description Framework (RDF) путем анализа синтаксиса
# RDF/XML, N-Triples, TRiG, Turtle, RSS tag soup включая все версии RSS, Atom
# 1.0 и 0.3, GRDDL и микроформаты для HTML, XHTML и XML

# Required:    curl
#              libxslt
# Recommended: no
# Optional:    gtk-doc
#              icu
#              libyajl (https://lloyd.github.com/yajl/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

INSTALL_GTK_DOC="false"
ICU=""
YAJL="--with-yajl=no"

command -v icu-config &>/dev/null && ICU="--with-icu-config=/usr/bin/icu-config"
[ -x /usr/lib/libyajl.so ] && YAJL="--with-yajl=yes"

# устраним несколько проблем с безопасностью
patch --verbose -Np1 \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-security_fixes-1.patch" || exit 1

./configure       \
    --prefix=/usr \
    ${ICU}        \
    "${YAJL}"     \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${INSTALL_GTK_DOC}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (RDF Parser & Serializer)
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
