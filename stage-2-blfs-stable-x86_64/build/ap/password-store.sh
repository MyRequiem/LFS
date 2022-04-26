#! /bin/bash

PRGNAME="password-store"

### password-store (password manager using GnuPG)
# Простой менеджер паролей, который использует GnuPG2 для безопасного
# шифрования и извлечения паролей. Утилита pass предоставляет ряд команд для
# управления хранилищем паролей, позволяющая добавлять, удалять, редактировать,
# синхронизировать и генерировать пароли.

# Required:    xclip
# Recommended: no
# Optional:    dmenu

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

PREFIX=/usr DESTDIR="${TMP_DIR}" make
PREFIX=/usr DESTDIR="${TMP_DIR}" make install

cp contrib/importers/* "${TMP_DIR}/usr/bin/"

# dmenu
command -v dmenu &>/dev/null && cp contrib/dmenu/passmenu "${TMP_DIR}/usr/bin/"

# установка плагина для vim
if command -v vim &>/dev/null; then
    VIMVER="$(vim --version | head -n 1 | awk '{ print $5; }' | tr -d .)"
    VIM_DIR="/usr/share/vim/vim${VIMVER}"
    mkdir -p "${TMP_DIR}${VIM_DIR}"/{doc,plugin}
    cp contrib/vim/*.vim "${TMP_DIR}${VIM_DIR}/plugin"
    cp contrib/vim/*.txt "${TMP_DIR}${VIM_DIR}/doc"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (password manager using GnuPG)
#
# password-store is a simple password manager which uses GnuPG2 to securely
# encrypt and retrieve passwords. The pass utility provides a series of
# commands for manipulating the password store, allowing the user to add,
# remove, edit, synchronize, generate, and manipulate passwords.
#
# Home page: https://www.passwordstore.org/
# Download:  https://git.zx2c4.com/${PRGNAME}/snapshot/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
