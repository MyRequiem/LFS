#! /bin/bash

PRGNAME="libgudev"

### libgudev (udev GObject bindings library)
# Библиотека предоставляет привязки GObject для libudev. Первоначально она была
# частью udev-extras, затем udev, затем systemd, и потом была выделена в
# отдельный проект.

# Required:    glib
# Recommended: no
# Optional:    gobject-introspection
#              gtk-doc                (для сборки API документации)
#              umockdev               (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson                   \
    --prefix=/usr       \
    --buildtype=release \
    -Dtests=disabled    \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (udev GObject bindings library)
#
# This is libgudev, a library providing GObject bindings for libudev. It used
# to be part of udev, but it's now a project on its own.
#
# Home page: http://wiki.gnome.org/Projects/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
