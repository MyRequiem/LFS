#! /bin/bash

PRGNAME="osinfo-db-tools"

### osinfo-db-tools (operating systems database tools)
# Инструменты для управления базой данных osinfo об операционных системах для
# использования с виртуализацией

# Required:    glib
#              json-glib
#              libarchive
#              libxml2
#              libxslt
#              libsoup2    (https://download.gnome.org/sources/libsoup/2.74/)
# Recommended: no
# Optional:    --- для тестов ---
#              python3-pytest
#              python3-requests

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..           \
    --prefix=/usr        \
    --buildtype=release  \
    --sysconfdir=/etc    \
    --localstatedir=/var || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (operating systems database tools)
#
# This package provides tools for managing the osinfo database of information
# about operating systems for use with virtualization
#
# Home page: https://libosinfo.org/
# Download:  https://releases.pagure.org/libosinfo/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
