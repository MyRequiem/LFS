#! /bin/bash

PRGNAME="glibmm26"

### GLibmm (C++ bindings for glib)
# Набор C++ bindings для GLib, включая кроссплатформенные API, такие как
# std::string-like (UTF8 строковый класс), строковые служебные методы для
# доступа к файлам и потокам

# Required:    glib
#              libsigc++2
# Recommended: no
# Optional:    doxygen
#              glib-networking (для тестов)
#              gnutls          (для тестов)
#              libxslt
#              mm-common       (https://download.gnome.org/sources/mm-common/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"
EXAMPLES="false"

mkdir bld
cd bld || exit 1

meson                               \
    --prefix=/usr                   \
    --buildtype=release             \
    -Dbuild-documentation="${DOCS}" \
    -Dbuild-examples="${EXAMPLES}"  \
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
# Home page: http://www.gtkmm.org/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
