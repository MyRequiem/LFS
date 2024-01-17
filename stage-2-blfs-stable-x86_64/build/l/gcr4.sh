#! /bin/bash

PRGNAME="gcr4"
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
#              gtk4
#              libsecret
#              libxslt
#              vala
# Optional:    python3-gi-docgen
#              valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-4*.tar.?z*" 2>/dev/null | sort | \
    head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"
GTK4="false"

# command -v gi-docgen &>/dev/null && DOCS="true"
command -v gtk4-demo &>/dev/null && GTK4="true"

# исправим устаревшие записи в файлах схем
sed -i 's:"/desktop:"/org:' schema/*.xml || exit 1

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    -Dgtk_doc="${DOCS}" \
    -Dgtk4="${GTK4}"    \
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
