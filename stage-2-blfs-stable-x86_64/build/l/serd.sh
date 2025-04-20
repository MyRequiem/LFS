#! /bin/bash

PRGNAME="serd"

### serd (Lightweight RDF syntax library)
# C-библиотека для анализа синтаксиса RDF, поддерживающая чтение и запись в
# Turtle and NTriples

# Required:    no
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
    --localstatedir=/var \
    --sysconfdir=/etc    \
    --buildtype=release  \
    -D tests=disabled    \
    -D docs=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Lightweight RDF syntax library)
#
# Serd is a lightweight C library for RDF syntax which supports reading and
# writing Turtle and NTriples
#
# Home page: https://drobilla.net/software/${PRGNAME}/
# Download:  https://download.drobilla.net/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
