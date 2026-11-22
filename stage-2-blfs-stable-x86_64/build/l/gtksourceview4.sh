#! /bin/bash

PRGNAME="gtksourceview4"
ARCH_NAME="gtksourceview"

### GtkSourceView (a GTK+ framework for source code editing)
# Библиотека расширения для GTK3, добавляющая в стандартный виджет GtkTextView
# поддержку номеров строк, подсветки синтаксиса и редактирование исходного кода
# в GUI-приложениях (например, в XML-редакторе virt-manager).

# Required:    gtk+3
# Recommended: glib
#              libxml2
# Optional:    vala
#              itstool

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..    \
    --prefix=/usr \
    --buildtype=release || exit 1

ninja || exit 1
# Тесты проводятся в графическом окружении.
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a GTK+ framework for source code editing)
#
# GtkSourceView is a GNOME library that extends GtkTextView, the standard GTK
# widget for multiline text editing. GtkSourceView adds support for syntax
# highlighting, undo/redo, file loading and saving, search and replace, a
# completion system, printing, displaying line numbers, and other features
# typical of a source code editor
#
# Home page: https://github.com/GNOME/${ARCH_NAME}/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
