#! /bin/bash

PRGNAME="goffice"

### GOffice (document utilities)
# Библиотека ориентированных на документы объектов GLib/GTK. Используется для
# выполнения общих операций с документами. Некоторые из операций,
# предоставляемых библиотекой GOffice, включают поддержку плагинов, процедуры
# загрузки/сохранения/отмены/повторения документов в приложениях.

# Required:    gtk+3
#              libgsf
#              librsvg
#              libxslt
#              which
# Recommended: no
# Optional:    ghostscript
#              gsettings-desktop-schemas
#              gtk-doc
#              lasem      (https://download.gnome.org/sources/lasem/)
#              libspectre (https://www.freedesktop.org/wiki/Software/libspectre/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

INSTALL_GTK_DOC="false"
GTK_DOC="--disable-gtk-doc"
# command -v gtkdoc-check  &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure       \
    --prefix=/usr \
    "${GTK_DOC}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${INSTALL_GTK_DOC}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (document utilities)
#
# The GOffice package contains a library of GLib/GTK document centric objects
# and utilities. This is useful for performing common operations for document
# centric applications that are conceptually simple, but complex to implement
# fully. Some of the operations provided by the GOffice library include support
# for plugins, load/save routines for application documents and undo/redo
# functions.
#
# Home page: https://ftp.gnome.org/pub/GNOME/sources/${PRGNAME}/
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
