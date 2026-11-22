#! /bin/bash

PRGNAME="osinfo-db-tools"

### osinfo-db-tools (operating systems database tools)
# Набор утилит для управления информационной базой данных об операционных
# системах. Эти инструменты помогают обновлять и проверять сведения,
# необходимые для правильной настройки виртуальных машин.

# Required:    glib
#              json-glib
#              libarchive
#              libxml2
#              libxslt
#              libsoup2
# Recommended: no
# Optional:    python3-requests

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d v -f 2)"

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    --sysconfdir=/etc   \
    --localstatedir=/var || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (operating systems database tools)
#
# This package provides tools for managing the osinfo database of information
# about operating systems for use with virtualization
#
# Home page: https://libosinfo.org/
# Download:  https://gitlab.com/libosinfo/${PRGNAME}/-/archive/v${VERSION}/${PRGNAME}-v${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
