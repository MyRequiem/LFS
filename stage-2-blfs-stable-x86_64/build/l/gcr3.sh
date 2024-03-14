#! /bin/bash

PRGNAME="gcr3"
ARCH_NAME="gcr"

### Gcr (crypto library and ui for gnome-keyring)
# Библиотеки для отображения сертификатов и доступа к криптографическому
# интерфейсу ключей. Также предоставляет средство просмотра зашифрованных
# файлов в GNOME

# Required:    glib
#              libgcrypt
#              p11-kit
# Recommended: gnupg
#              gobject-introspection
#              gtk+3
#              libsecret
#              libxslt
#              vala
# Optional:    python3-gi-docgen
#              valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-3*.tar.?z*" 2>/dev/null | sort | \
    head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"
GTK3="false"

# command -v gi-docgen &>/dev/null && DOCS="true"
command -v gtk3-demo &>/dev/null && GTK3="true"

# исправим устаревшие записи в файлах схем
sed -i 's:"/desktop:"/org:' schema/*.xml || exit 1

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    -Dgtk_doc="${DOCS}" \
    -Dgtk="${GTK3}"     \
    .. || exit 1

ninja || exit 1

# тесты запускаются только в графической среде
# ninja test

DESTDIR="${TMP_DIR}" ninja install

[ "x${DOCS}" == "xfalse" ] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (crypto library and ui for gnome-keyring)
#
# GCR is a library for displaying certificates and crypto UI accessing key
# stores. It also provides the viewer for crypto files on the GNOME desktop.
#
# Home page: https://www.gnome.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
