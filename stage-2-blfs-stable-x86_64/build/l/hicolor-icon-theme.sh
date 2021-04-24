#! /bin/bash

PRGNAME="hicolor-icon-theme"

### hicolor-icon-theme (default icon theme)
# Default fallback icon theme

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (default icon theme)
#
# This is the default fallback theme used by implementations of the icon theme
# specification. The specification is available at:
#    https://specifications.freedesktop.org/icon-theme-spec/latest/
#
# Home page: https://www.freedesktop.org/wiki/Software/icon-theme/
# Download:  https://icon-theme.freedesktop.org/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
