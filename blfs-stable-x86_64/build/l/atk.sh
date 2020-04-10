#! /bin/bash

PRGNAME="atk"

### ATK
# Библиотека функций, которая используется инструментарием GTK+-2

# http://www.linuxfromscratch.org/blfs/view/9.0/x/atk.html

# Home page: http://ftp.gnome.org/pub/gnome/sources/atk/
# Download:  http://ftp.gnome.org/pub/gnome/sources/atk/2.32/atk-2.32.0.tar.xz

# Required:    glib
# Recommended: gobject-introspection (требуется для сборки GNOME)
# Optional:    gtk-doc

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

mkdir -pv build
cd build || exit 1

meson \
    --prefix=/usr || exit 1

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
