#! /bin/bash

PRGNAME="libxslt"

### libxslt (XML transformation library)
# Библиотеки поддержки XSLT для libxml2
# (XSLT - язык, используемый для преобразования документов XML)

# Required:    libxml2
# Recommended: docbook-xml
#              docbook-xsl
# Optional:    libgcrypt
#              python2-libxml2

### NOTE:
# Recommended: docbook-xml и docbook-xsl
#    хоть зависимости и не прямые, но многие приложения, использующие libxslt
#    ожидают наличия этих двух пакетов

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"
GTK_DOC="false"
DOC_DIR="/usr/share/doc"

./configure                 \
    --prefix=/usr           \
    --disable-static        \
    PYTHON=/usr/bin/python3 \
    --docdir="${DOC_DIR}/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[ "${DOCS}" == "false" ]    && rm -rf "${TMP_DIR}${DOC_DIR}"
[ "${GTK_DOC}" == "false" ] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML transformation library)
#
# XSLT support for libxml2 (XSLT is a language used for transforming XML
# documents)
#
# Home page: http://xmlsoft.org/XSLT/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
