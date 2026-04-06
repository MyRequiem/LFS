#! /bin/bash

PRGNAME="vifm"

### Vifm (a ncurses-based file manager with vi-like keybindings)
# Двухпанельный файловый менеджер для консоли на основе ncurses с управлением в
# стиле редактора Vim.

# Required:    glib
# Recommended: --- runtime ---
#              sshfs
#              fuse3
#              rclone
#              archivemount
#              highlight
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

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
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
