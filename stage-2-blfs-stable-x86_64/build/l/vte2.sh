#! /bin/bash

PRGNAME="vte2"
ARCH_NAME="vte"

### VTE (terminal emulator widget for use with GTK+2)
# Виджет эмулятора терминала использующий GTK+2. Пакет содержит библиотеку VTE
# и минимальное демонстрационное приложение vte, которое использует libvte

# Required:    gtk+2
# Recommended: no
# Optional:    gobject-introspection
#              gtk-doc
#              python2-pygtk

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-0.2*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# документация
DOCS="false"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --libexecdir=/usr/lib/vte || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${DOCS}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (terminal emulator widget for use with GTK+2)
#
# VTE is a terminal emulator widget for use with GTK+2. This package contains
# the VTE library, development files a minimal demonstration application 'vte'
# that uses libvte
#
# Home page: https://wiki.gnome.org/Apps/Terminal/VTE
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
