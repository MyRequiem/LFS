#! /bin/bash

PRGNAME="glibmm28"
ARCH_NAME="glibmm"

### GLibmm (C++ bindings for glib)
# Набор C++ bindings для GLib, включая кроссплатформенные API, такие как
# std::string-like (UTF8 строковый класс), строковые служебные методы для
# доступа к файлам и потокам

# Required:    glib
#              libsigc++3
# Recommended: no
# Optional:    doxygen
#              glib-networking (для тестов)
#              gnutls          (для тестов)
#              libxslt
#              mm-common       (https://download.gnome.org/sources/mm-common/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-2.8*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir bld
cd bld || exit 1

meson setup                      \
    --prefix=/usr                \
    --buildtype=release          \
    -D build-documentation=false \
    -D build-examples=false      \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++ bindings for glib)
#
# The GLibmm package is a set of C++ bindings for GLib, including
# cross-platform APIs such as a std::string-like UTF8 string class, string
# utility methods, such as a text encoding converter API, file access, and
# threads.
#
# Home page: https://www.gtkmm.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
