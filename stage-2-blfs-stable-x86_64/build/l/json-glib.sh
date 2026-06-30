#! /bin/bash

PRGNAME="json-glib"

### JSON-GLib (a de/serialization library for the JS Object Notation)
# Библиотека, позволяющая программам легко читать и записывать данные в формате
# JSON. Создана специально для интеграции с программной средой  GNOME и
# использует ее стандарты типов данных (GObject).

# Required:    glib
# Recommended: no
# Optional:    python3-docutils     (для создания man-страниц)
#              python3-gi-docgen    (для создания документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D man=true         \
    -D tests=false      \
    -D gtk_doc=disabled \
    -D documentation=disabled || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a de/serialization library for the JS Object Notation)
#
# JSON-GLib is a library providing serialization and deserialization support
# for the JavaScript Object Notation (JSON) format described by RFC 4627.
#
# Home page: https://live.gnome.org/JsonGlib
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
