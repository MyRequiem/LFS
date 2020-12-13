#! /bin/bash

PRGNAME="dbus-glib"

### dbus-glib (Glib bindings for D-Bus)
# Glib bindings (Glib интерфейсы) для D-Bus API

# Required:    dbus
#              glib
# Recommended: no
# Optional:    gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="no"
GTK_DOC_HTML="no"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="yes" && GTK_DOC_HTML="yes"

./configure                       \
    --prefix=/usr                 \
    --sysconfdir=/etc             \
    --disable-static              \
    --enable-gtk-doc="${GTK_DOC}" \
    --enable-gtk-doc-html="${GTK_DOC_HTML}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${GTK_DOC}" == "xno" && "x${GTK_DOC_HTML}" == "xno" ]] && \
    rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
