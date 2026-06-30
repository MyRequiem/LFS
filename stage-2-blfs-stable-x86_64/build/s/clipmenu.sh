#! /bin/bash

PRGNAME="clipmenu"

### clipmenu (simple clipboard manager using dmenu)
# Удобная история буфера обмена, построенная на базе dmenu. Она хранит всё, что
# вы копировали ранее, позволяет быстро выбрать нужный фрагмент из списка и
# вставить его снова.

# Required:    clipnotify
#              dmenu
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

install -m755 -o root -g root "${SOURCES}/clearclipmenu" clipmenu clipmenud \
    "${TMP_DIR}/usr/bin" || exit 1

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
