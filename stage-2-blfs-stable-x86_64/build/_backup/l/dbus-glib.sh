#! /bin/bash

PRGNAME="dbus-glib"

### dbus-glib (Glib bindings for D-Bus)
# Glib bindings (Glib интерфейсы) для D-Bus API

# http://www.linuxfromscratch.org/blfs/view/stable/general/dbus-glib.html

# Home page: https://dbus.freedesktop.org/
# Download:  https://dbus.freedesktop.org/releases/dbus-glib/dbus-glib-0.110.tar.gz

# Required: dbus
#           glib
# Optional: gtk-doc

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    "${GTK_DOC}"      \
    --disable-static || exit 1

make || exit 1
# make check
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Glib bindings for D-Bus)
#
# This package includes the Glib bindings (GLib interfaces) for the D-Bus API
# library
#
# Home page: https://dbus.freedesktop.org/
# Download:  https://dbus.freedesktop.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
