#! /bin/bash

PRGNAME="gobject-introspection"

### gobject-introspection
#

# http://www.linuxfromscratch.org/blfs/view/9.0/general/gobject-introspection.html

# Home page: http://live.gnome.org/GObjectIntrospection
# Download:  http://ftp.gnome.org/pub/gnome/sources/gobject-introspection/1.60/gobject-introspection-1.60.2.tar.xz

# Required: glib
# Optional: cairo
#           gjs
#           gtk-doc
#           mako
#           markdown

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

mkdir -pv build
cd build || exit 1

meson \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1
# ninja test -k0
ninja install
DESTDIR="${TMP_DIR}" ninja install

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GObject interface introspection library)
#
# GObject Introspection is a project for providing machine readable
# introspection data of the API of C libraries. This introspection data can be
# used for automatic code generation for bindings, API verification, and
# documentation generation.
#
# Home page: http://live.gnome.org/GObjectIntrospection
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
