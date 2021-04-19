#! /bin/bash

PRGNAME="atk"

### ATK (accessibility functions library)
# Библиотека функций, которая используется инструментарием GTK+-2

# Required:    glib
# Recommended: gobject-introspection
# Optional:    gtk-doc (для сборки API документации)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -pv build
cd build || exit 1

INTROSPECTION="false"
GTK_DOC="false"

command -v g-ir-compiler &>/dev/null  && INTROSPECTION="true"
# command -v gtkdoc-check  &>/dev/null  && GTK_DOC="true"

meson                                  \
    --prefix=/usr                      \
    -Ddocs="${GTK_DOC}"                \
    -Dintrospection="${INTROSPECTION}" \
    .. || exit 1

ninja || exit 1
# пакет не содержит набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (accessibility functions library)
#
# ATK provides the set of accessibility interfaces that are implemented by
# other toolkits and applications. Using the ATK interfaces, accessibility
# tools have full access to view and control running applications.
#
# Home page: http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/
# Download:  http://ftp.gnome.org/pub/gnome/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
