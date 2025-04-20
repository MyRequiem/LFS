
#! /bin/bash

PRGNAME="appstream-glib"

### appstream-glib (library for reading and writing AppStream metadata)
# библиотека, предоставляющая Gobjects и вспомогательные утилиты, для
# облегчения чтения и записи метаданных

# Required:    curl
#              gdk-pixbuf
#              libarchive
# Recommended: no
# Optional:    docbook-xml
#              docbook-xsl
#              gtk-doc
#              libxslt
#              libyaml

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

chmod 644 "${TMP_DIR}/usr/share/man/man1/"*
rm -rf "${TMP_DIR}/usr/share/installed-tests"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
