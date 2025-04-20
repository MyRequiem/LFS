#! /bin/bash

PRGNAME="lilv"

### lilv (LV2 Library)
# C-библиотека, для использования плагинов LV2. Является преемником SLV2

# Required:    python3-numpy
#              sratom
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build

export PYTHON=python3
meson ..                 \
    --prefix=/usr        \
    --buildtype=release  \
    --localstatedir=/var \
    --sysconfdir=/etc    \
    -D docs=disabled     \
    -D tests=disabled || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (LV2 Library)
#
# Lilv is a C library to make the use of LV2 plugins as simple as possible for
# applications. Lilv is the successor to SLV2, rewritten to be significantly
# faster and have minimal dependencies. It is stable, well-tested software (the
# included test suite covers over 90% of the code) in use by several
# applications.
#
# Home page: https://drobilla.net/software/${PRGNAME}/
# Download:  https://download.drobilla.net/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
