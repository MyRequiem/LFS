#! /bin/bash

PRGNAME="gobject-introspection"

### gobject-introspection (GObject interface introspection library)
# Проект для самоанализа API C-библиотек и предоставления машиночитаемых
# данных. Эти данные могут быть использованы для автоматической генерации кода
# для привязок, проверки API и генерация документации.

# Required:    glib
#              python3
# Recommended: no
# Optional:    cairo                (для тестов)
#              gjs                  (для прохождния одного теста)
#              gtk-doc              (для сборки документации)
#              python3-mako         (для сборки _giscanner.cpython-38-x86_64-linux-gnu.so и утилиты g-ir-doc-tool)
#              python3-markdown     (для утилиты g-ir-doc-tool и прохождения одного теста) https://pypi.org/project/Markdown/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -pv build
cd build || exit 1

CAIRO="-Dcairo=disabled"
GTK_DOC="-Dgtk_doc=false"
MAKO=""
MARKDOWN=""
DOCTOOL="-Ddoctool=disabled"

command -v cairo-sphinx &>/dev/null && CAIRO="-Dcairo=enabled"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="-Dgtk_doc=true"
command -v mako-render  &>/dev/null && MAKO="true"
command -v markdown_py  &>/dev/null && MARKDOWN="true"

[[ -n "${MAKO}" && -n "${MARKDOWN}" ]] && DOCTOOL="-Ddoctool=enabled"

meson \
    --prefix=/usr \
    "${CAIRO}"    \
    "${GTK_DOC}"  \
    "${DOCTOOL}"  \
    .. || exit 1

ninja || exit 1

# для одного теста (test_docwriter) требуется пакет python3-markdown
# ninja test -k0

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
