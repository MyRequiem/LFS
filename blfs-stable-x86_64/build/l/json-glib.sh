#! /bin/bash

PRGNAME="json-glib"

### JSON-GLib
# Библиотека, обеспечивающая поддержку сериализации и десериализации
# формата JSON (JavaScript Object Notation), описанного в RFC 4627

# http://www.linuxfromscratch.org/blfs/view/9.0/general/json-glib.html

# Home page: http://live.gnome.org/JsonGlib
# Download:  http://ftp.gnome.org/pub/gnome/sources/json-glib/1.4/json-glib-1.4.4.tar.xz

# Required: glib
# Optional: gobject-introspection (required ifbuilding GNOME)
#           gtk-doc

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson             \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1
# ninja test
ninja install
DESTDIR="${TMP_DIR}" ninja install

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a de/serialization library for the JS Object Notation)
#
# JSON-GLib is a library providing serialization and deserialization support
# for the JavaScript Object Notation (JSON) format described by RFC 4627
#
# Home page: http://live.gnome.org/JsonGlib
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
