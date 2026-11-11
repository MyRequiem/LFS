#! /bin/bash

PRGNAME="password-store"

### password-store (password manager using GnuPG)
# Система хранения паролей, созданная по принципу «всё гениальное - просто».
# Она шифрует ваши секреты с помощью GnuPG ключей и хранит их в виде обычных
# файлов, которые легко переносить. Предоставляет ряд команд для управления
# хранилищем паролей, позволяющая добавлять, удалять, редактировать,
# синхронизировать и генерировать пароли.

# Required:    xclip
# Recommended: no
# Optional:    dmenu

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_NAME="$(find "${SOURCES}" -type f -name "${PRGNAME}-*" | rev | \
    cut -d / -f 1 | rev)"
VERSION="$(echo "${ARCH_NAME}" | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

# Имя директории внутри архива.
ARCH_DIR_NAME="$(tar -tf "${SOURCES}/${ARCH_NAME}" 2>/dev/null | head -n 1 | \
    cut -d / -f 1)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}" || exit 1
cd "${ARCH_DIR_NAME}" || exit 1

chown -R root:root .
find -L . \
\( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
-o -perm 511 \) -exec chmod 755 {} \+ -o \
\( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
-o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

PREFIX=/usr DESTDIR="${TMP_DIR}" make
PREFIX=/usr DESTDIR="${TMP_DIR}" make install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

install -m755 contrib/importers/*    "${TMP_DIR}/usr/bin/" || exit 1
install -m755 contrib/dmenu/passmenu "${TMP_DIR}/usr/bin/" || exit 1

# Установка плагина для vim.
VIMVER="$(vim --version | head -n 1 | awk '{ print $5; }' | tr -d .)"
VIM_DIR="/usr/share/vim/vim${VIMVER}"
install -m644 -D -t "${TMP_DIR}${VIM_DIR}/plugin" contrib/vim/*.vim || exit 1
install -m644 -D -t "${TMP_DIR}${VIM_DIR}/doc"    contrib/vim/*.txt || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
# Download:  https://github.com/zx2c4/${PRGNAME}/tarball/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
