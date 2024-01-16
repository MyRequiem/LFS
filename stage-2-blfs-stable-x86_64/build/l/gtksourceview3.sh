#! /bin/bash

PRGNAME="gtksourceview3"
ARCH_NAME="gtksourceview"

### GtkSourceView (a GTK+ framework for source code editing)
# GTK библиотека, расширяющая возможности GtkTextView - виджета для
# редактирования исходного кода GTK. Поддерживает подсветку синтаксиса,
# выделение, отмена/повтор, поиск, замена и т.д.

# Required:    gtk+3
# Recommended: gobject-introspection
# Optional:    vala
#              valgrind
#              gtk-doc
#              itstool
#              fop или dblatex (https://sourceforge.net/projects/dblatex/)
#              glade           (https://glade.gnome.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f \
    -name "${ARCH_NAME}-3*.tar.?z*" 2>/dev/null | sort | \
    head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1
tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

INSTALL_GTK_DOC="false"
GTK_DOC="--disable-gtk-doc"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

./configure       \
    --prefix=/usr \
    "${GTK_DOC}"  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

[[ "x${INSTALL_GTK_DOC}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a GTK+ framework for source code editing)
#
# GtkSourceView is a GNOME library that extends GtkTextView, the standard GTK
# widget for multiline text editing. GtkSourceView adds support for syntax
# highlighting, undo/redo, file loading and saving, search and replace, a
# completion system, printing, displaying line numbers, and other features
# typical of a source code editor.
#
# Home page: https://projects.gnome.org/${ARCH_NAME}/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/3.24/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
