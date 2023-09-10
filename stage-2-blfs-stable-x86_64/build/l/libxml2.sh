#! /bin/bash

PRGNAME="libxml2"

### libxml2 (XML parser library)
# Библиотеки и утилиты для анализа XML файлов

# Required:    no
# Recommended: no
# Optional:    icu      (для лучшей поддержки UNICODE)
#              valgrind (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

ICU="--without-icu"
command -v icuinfo &>/dev/null && ICU="--with-icu"

DOCS="false"
GTK_DOC="false"
DOC_DIR="/usr/share/doc"

# включает поддержку Readline при запуске xmlcatalog или xmllint в консоли
#    --with-history
# собирать модуль libxml2 для Python3 вместо Python2
#    PYTHON=/usr/bin/python3
./configure                 \
    --prefix=/usr           \
    --sysconfdir=/etc       \
    --disable-static        \
    --with-history          \
    "${ICU}"                \
    PYTHON=/usr/bin/python3 \
    --docdir="${DOC_DIR}/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

[ "${DOCS}" == "false" ]    && rm -rf "${TMP_DIR}${DOC_DIR}"
[ "${GTK_DOC}" == "false" ] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XML parser library)
#
# Libxml2 is the XML C parser library and toolkit. XML itself is a metalanguage
# to design markup languages -- i.e. a text language where structures are added
# to the content using extra "markup" information enclosed between angle
# brackets. HTML is the most well-known markup language. Though the library is
# written in C, a variety of language bindings make it available in other
# environments.
#
# Home page: http://xmlsoft.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
