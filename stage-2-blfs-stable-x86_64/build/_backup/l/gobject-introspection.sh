#! /bin/bash

PRGNAME="gobject-introspection"

### gobject-introspection (GObject interface introspection library)
# Проект для самоанализа API C-библиотек и предоставления машиночитаемых
# данных. Эти данные могут быть использованы для автоматической генерации кода
# для привязок, проверки API и генерация документации.

# http://www.linuxfromscratch.org/blfs/view/stable/general/gobject-introspection.html

# Home page: http://live.gnome.org/GObjectIntrospection
# Download:  http://ftp.gnome.org/pub/gnome/sources/gobject-introspection/1.62/gobject-introspection-1.62.0.tar.xz

# Required: glib
# Optional: cairo    (для тестов)
#           gtk-doc  (для сборки документации)
#           gjs      (для прохождния одного теста)
#           python3-mako (для сборки _giscanner.cpython-37m-x86_64-linux-gnu.so и утилиты g-ir-doc-tool)
#           markdown (для прохождния одного теста) https://pypi.org/project/Markdown/

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -pv build
cd build || exit 1

CAIRO="-Dcairo=false"
GTK_DOC="-Dgtk_doc=false"
DOCTOOL="-Ddoctool=false"

command -v cairo-sphinx &>/dev/null && CAIRO="-Dcairo=true"
command -v gtkdoc-check &>/dev/null && GTK_DOC="-Dgtk_doc=true"
command -v mako-render  &>/dev/null && DOCTOOL="-Ddoctool=true"

meson \
    --prefix=/usr \
    "${CAIRO}"    \
    "${GTK_DOC}"  \
    "${DOCTOOL}"  \
    .. || exit 1

ninja || exit 1
# для одного теста (test_docwriter) требуется пакет markdown
# ninja test -k0
ninja install
DESTDIR="${TMP_DIR}" ninja install

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GObject interface introspection library)
#
# GObject Introspection is a project for providing machine readable
# introspection data of the API of C libraries. This introspection data can be
# used for automatic code generation for bindings, API verification, and
# documentation generation.
#
# Home page: http://live.gnome.org/GObjectIntrospection
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
