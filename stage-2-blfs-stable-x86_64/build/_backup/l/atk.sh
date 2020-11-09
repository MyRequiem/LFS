#! /bin/bash

PRGNAME="atk"

### ATK (accessibility functions library)
# Библиотека функций, которая используется инструментарием GTK+-2

# http://www.linuxfromscratch.org/blfs/view/stable/x/atk.html

# Home page: http://ftp.gnome.org/pub/gnome/sources/atk/
# Download:  http://ftp.gnome.org/pub/gnome/sources/atk/2.34/atk-2.34.1.tar.xz

# Required:    glib
# Recommended: gobject-introspection
# Optional:    gtk-doc (для сборки API документации)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -pv build
cd build || exit 1

INTROSPECTION="-Dintrospection=false"
GTK_DOC="-Ddocs=false"

command -v g-ir-compiler &>/dev/null  && INTROSPECTION="-Dintrospection=true"
command -v gtkdoc-check  &>/dev/null  && GTK_DOC="-Ddocs=true"

meson                   \
    --prefix=/usr       \
    "${INTROSPECTION}"  \
    "${GTK_DOC}"        \
    .. || exit 1

ninja || exit 1
# пакет не содержит набора тестов
ninja install
DESTDIR="${TMP_DIR}" ninja install

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (accessibility functions library)
#
# ATK provides the set of accessibility interfaces that are implemented by
# other toolkits and applications. Using the ATK interfaces, accessibility
# tools have full access to view and control running applications.
#
# Home page: http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
