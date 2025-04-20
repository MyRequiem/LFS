#! /bin/bash

PRGNAME="sratom"

### sratom (LV2 Serializing to/from RDF)
# Библиотека для сериализации LV2 в/из RDF

# Required:    lv2
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson ..                 \
    --prefix=/usr        \
    --buildtype=release  \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    -D docs=disabled     \
    -D tests=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (LV2 Serializing to/from RDF)
#
# Sratom is a library for serialising LV2 atoms to/from RDF, particularly the
# Turtle syntax
#
# Home page: https://drobilla.net/software/${PRGNAME}/
# Download:  https://download.drobilla.net/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
