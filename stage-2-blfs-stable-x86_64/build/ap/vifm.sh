#! /bin/bash

PRGNAME="vifm"

### Vifm (a ncurses-based file manager with vi-like keybindings)
# Файловый менеджер на основе ncurses с сочетаниями клавиш в стиле Vi

# Required:    no
# Recommended: no
# Optional:    sshfs
#              curlftpfs
#              fuse2
#              fuse3
#              fuse-zip
#              fusefat
#              fuseiso
#              archivemount
#              highlight

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/${DOCS}"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir="${DOCS}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a ncurses-based file manager with vi-like keybindings)
#
# If you use vi, vifm gives you complete keyboard control over your files
# without having to learn a new set of commands. The configuration for vifm
# sits in ~/.vifm
#
# Home page: https://${PRGNAME}.info/
# Download:  https://prdownloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
