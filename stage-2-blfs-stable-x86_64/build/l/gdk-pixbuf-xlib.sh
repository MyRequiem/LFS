#! /bin/bash

PRGNAME="gdk-pixbuf-xlib"

### gdk-pixbuf-xlib (image library used by GTK+ v2/3)
# Предоставляет устаревший интерфейс Xlib для gdk-pixbuf, необходимый для
# некоторых приложений, которые пока не были перенесены на новый интерфейс

# Required:    gdk-pixbuf
#              xorg-libraries
# Recommended: no
# Optional:    gtk-doc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="false"
# command -v gtkdoc-check  &>/dev/null  && GTK_DOC="true"

mkdir build
cd build || exit 1

meson                      \
    --prefix=/usr          \
    -Dgtk_doc="${GTK_DOC}" \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (image library used by GTK+ v2/3)
#
# The gdk-pixbuf-xlib package provides a deprecated Xlib interface to
# gdk-pixbuf, which is needed for some applications which have not been ported
# to use the new interfaces yet.
#
# Home page: https://gitlab.gnome.org/GNOME/gdk-pixbuf/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
