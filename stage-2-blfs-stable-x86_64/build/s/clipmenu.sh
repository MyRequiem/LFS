#! /bin/bash

PRGNAME="clipmenu"

### clipmenu (simple clipboard manager using dmenu)
# простой менеджер буфера обмена, использующий dmenu или rofi

# Required:    clipnotify
#              xsel
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/bin"

patch --verbose -p1 -i \
    "${SOURCES}/set-cachedir-path-to-home-dir_cache-${VERSION}.diff" || exit 1

cp "${SOURCES}/clearclipmenu" clipmenu clipmenud "${TMP_DIR}/usr/bin"
chmod 755 "${TMP_DIR}/usr/bin"/*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (simple clipboard manager using dmenu)
#
# simple clipboard manager using dmenu (or rofi with CM_LAUNCHER=rofi) and xsel
#
# Home page: https://github.com/cdown/${PRGNAME}
# Download:  https://github.com/MyRequiem/LFS/raw/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
