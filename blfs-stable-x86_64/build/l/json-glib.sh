#! /bin/bash

PRGNAME="json-glib"

### JSON-GLib (a de/serialization library for the JS Object Notation)
# Библиотека, обеспечивающая поддержку сериализации и десериализации
# формата JSON (JavaScript Object Notation), описанного в RFC 4627

# http://www.linuxfromscratch.org/blfs/view/stable/general/json-glib.html

# Home page: http://live.gnome.org/JsonGlib
# Download:  http://ftp.gnome.org/pub/gnome/sources/json-glib/1.4/json-glib-1.4.4.tar.xz

# Required: glib
# Optional: gobject-introspection
#           libxslt (для сборки man-страниц)
#           gtk-doc (для сборки API документации)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

INTROSPECTION="-Dintrospection=false"
MAN="-Dman=false"
GTK_DOC="-Ddoc=false"

command -v g-ir-compiler &>/dev/null && INTROSPECTION="-Dintrospection=true"
command -v xslt-config   &>/dev/null && MAN="-Dman=true"
# для сборки API документации требуется libxslt и gtk-doc
[[ "x${MAN}" == "x-Dman=true" ]] && \
    command -v gtkdoc-check  &>/dev/null && GTK_DOC="-Ddoc=true"

meson                  \
    --prefix=/usr      \
    "${INTROSPECTION}" \
    "${MAN}"           \
    "${GTK_DOC}"       \
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
