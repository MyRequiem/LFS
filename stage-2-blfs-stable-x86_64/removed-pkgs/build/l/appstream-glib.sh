#! /bin/bash

PRGNAME="appstream-glib"

### appstream-glib (library for reading and writing AppStream metadata)
# Набор инструментов для работы с метаданными AppStream, которые описывают
# установленные в системе приложения. Он используется графическими магазинами
# софта для показа скриншотов и описаний.

# Required:    curl
#              gdk-pixbuf
#              gtk+3
#              json-glib
#              libarchive
#              libyaml
# Recommended: no
# Optional:    docbook-xml
#              docbook-xsl
#              gtk-doc
#              libxslt

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
    -D rpm=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for reading and writing AppStream metadata)
#
# This library provides GObjects and helper methods to make it easy to read and
# write AppStream metadata.
#
# Home page: https://github.com/hughsie/${PRGNAME}
# Download:  https://people.freedesktop.org/~hughsient/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
