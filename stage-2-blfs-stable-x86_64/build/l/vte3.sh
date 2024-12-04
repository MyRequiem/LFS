#! /bin/bash

PRGNAME="vte3"
ARCH_NAME="vte"

### VTE (terminal emulator widget for use with GTK+3)
# Виджет эмулятора терминала использующий GTK+3. Пакет содержит библиотеку VTE
# и минимальное демонстрационное приложение vte, которое использует libvte

# Required:    gtk+3
#              libxml2
#              pcre2
# Recommended: icu
#              gnutls
#              vala
# Optional:    fribidi
#              python3-gi-docgen
#              gtk4

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-0.7*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

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
INTROSPECTION="false"
FRIBIDI="false"
GNUTLS="false"
GTK4="false"
ICU="false"
VALA="false"

command -v gtkdoc-check  &>/dev/null && DOCS="true"
command -v g-ir-compiler &>/dev/null && INTROSPECTION="true"
command -v fribidi       &>/dev/null && FRIBIDI="true"
command -v certtool      &>/dev/null && GNUTLS="true"
command -v gtk4-launch   &>/dev/null && GTK4="true"
command -v derb          &>/dev/null && ICU="true"
command -v vala          &>/dev/null && VALA="true"

mkdir build
cd build || exit 1

meson                        \
    --prefix=/usr            \
    --buildtype=release      \
    -Ddocs="${DOCS}"         \
    -Dgir="${INTROSPECTION}" \
    -Dfribidi="${FRIBIDI}"   \
    -Dgnutls="${GNUTLS}"     \
    -Dgtk4="${GTK4}"         \
    -Dicu="${ICU}"           \
    -Dvapi="${VALA}"         \
    -D_systemd=false         \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# удалим 2 файла /etc/profile.d/{vte.csh,vte.sh}, которые не используются в LFS
# системе
rm -v "${TMP_DIR}/etc/profile.d/vte."*

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (terminal emulator widget for use with GTK+3)
#
# VTE is a terminal emulator widget for use with GTK+3. This package contains
# the VTE library, development files a minimal demonstration application 'vte'
# that uses libvte
#
# Home page: https://wiki.gnome.org/Apps/Terminal/VTE
# Download:  https://gitlab.gnome.org/GNOME/${ARCH_NAME}/-/archive/${VERSION}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
