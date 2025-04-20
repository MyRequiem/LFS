#! /bin/bash

PRGNAME="sord"

### sord (Lightweight RDF Storing library)
# C-библиотека для хранения данных RDF в памяти

# Required:    serd
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
    --localstatedir=/var \
    --sysconfdir=/etc    \
    -D tests=disabled    \
    -D docs=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Lightweight RDF Storing library)
#
# Sord is a lightweight C library for storing RDF data in memory
#
# Home page: https://drobilla.net/software/${PRGNAME}/
# Download:  https://download.drobilla.net/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
