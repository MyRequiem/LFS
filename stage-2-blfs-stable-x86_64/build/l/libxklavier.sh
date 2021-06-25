#! /bin/bash

PRGNAME="libxklavier"

### libxklavier (XKB Library)

# Required:    glib
#              iso-codes
#              libxml2
#              xorg-libraries
# Recommended: gobject-introspection
# Optional:    gtk-doc
#              vala

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="no"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="yes"

./configure                       \
    --prefix=/usr                 \
    --disable-static              \
    --enable-gtk-doc="${GTK_DOC}" \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

[[ "x${GTK_DOC}" == "xno" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XKB Library)
#
# libxklavier is a utility library to make XKB stuff easier for X keyboard
#
# Home page: http://www.freedesktop.org/wiki/Software/LibXklavier
# Download:  https://people.freedesktop.org/~svu/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
