#! /bin/bash

PRGNAME="libgudev"

### libgudev (udev GObject bindings library)
# Библиотека предоставляет привязки GObject для libudev. Первоначально она была
# частью udev-extras, затем udev, затем systemd, и потом была выделена в
# отдельный проект.

# http://www.linuxfromscratch.org/blfs/view/stable/general/libgudev.html

# Home page: http://wiki.gnome.org/Projects/libgudev
# Download:  http://ftp.gnome.org/pub/gnome/sources/libgudev/233/libgudev-233.tar.xz

# Required: glib
# Optional: gobject-introspection
#           gtk-doc  (для сборки API документации)
#           umockdev (https://github.com/martinpitt/umockdev)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

INTROSPECTION="no"
GTK_DOC="--disable-gtk-doc"
UMOCKDEV="--disable-umockdev"

command -v g-ir-compiler &>/dev/null && INTROSPECTION="yes"
command -v gtkdoc-check  &>/dev/null && GTK_DOC="--enable-gtk-doc"
command -v umockdev-run  &>/dev/null && UMOCKDEV="--enable-umockdev"

./configure                                   \
    --prefix=/usr                             \
    --enable-introspection="${INTROSPECTION}" \
    "${GTK_DOC}"                              \
    "${UMOCKDEV}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (udev GObject bindings library)
#
# This is libgudev, a library providing GObject bindings for libudev. It used
# to be part of udev, but it's now a project on its own.
#
# Home page: http://wiki.gnome.org/Projects/${PRGNAME}
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
