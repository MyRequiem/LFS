#! /bin/bash

PRGNAME="libproxy"

### libproxy (automatic proxy configuration management)
# Библиотека, обеспечивающая автоматическую настройку прокси

# Required:    no
# Recommended: curl
#              duktape
#              glib
#              python3-gi-docgen
#              gsettings-desktop-schemas
#              vala
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..      \
    --prefix=/usr   \
    -D release=true \
    -D docs=false   \
    -D tests=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (automatic proxy configuration management)
#
# The libproxy package is a library that provides automatic proxy configuration
# management. This is useful in standardizing a way of dealing with proxy
# settings across all scenarios
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
