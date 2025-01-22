#! /bin/bash

PRGNAME="json-glib"

### JSON-GLib (a de/serialization library for the JS Object Notation)
# Библиотека, обеспечивающая поддержку сериализации и десериализации для
# формата JavaScript Object Notation (JSON), описанного в RFC 4627

# Required:    glib
# Recommended: no
# Optional:    gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    -D man=true         \
    -D gtk_doc=disabled \
    -D tests=false      \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

chmod 644 "${TMP_DIR}/usr/share/man/man1"/*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a de/serialization library for the JS Object Notation)
#
# JSON-GLib is a library providing serialization and deserialization support
# for the JavaScript Object Notation (JSON) format described by RFC 4627.
#
# Home page: http://live.gnome.org/JsonGlib
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
