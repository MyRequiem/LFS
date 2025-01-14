#! /bin/bash

PRGNAME="dmenu"

### dmenu (dynamic menu for X)
# Универсальное и удобное меню для X

# Required:    no
# Recommended: no
# Optional:    --- runtime ---
#              password-store
#              clipmenu
#              xsel

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make install PREFIX=/usr DESTDIR="${TMP_DIR}"

cp "${SOURCES}/dmenu_pass" "${TMP_DIR}/usr/bin"
chown root:root "${TMP_DIR}/usr/bin"/*
chmod 755 "${TMP_DIR}/usr/bin"/*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (dynamic menu for X)
#
# dmenu is a generic and efficient menu for X
#
# Home page: https://tools.suckless.org/${PRGNAME}/
# Download:  https://dl.suckless.org/tools/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
