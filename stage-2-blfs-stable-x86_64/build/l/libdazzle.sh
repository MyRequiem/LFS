#! /bin/bash

PRGNAME="libdazzle"

### libdazzle (GObject and GTK+ APIs for special graphical effects)
# Вспомогательная библиотека для GObject и GTK+, которая добавляет API для
# специальных графических эффектов

# Required:    gtk+3
# Recommended: vala
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

TESTS="false"
GTK_DOC="false"
VALA_API="false"

# command -v gtkdoc-check &>/dev/null && GTK_DOC="true"
command -v vala &>/dev/null && VALA_API="true"

mkdir build
cd build || exit 1

meson                             \
    --prefix=/usr                 \
    -Denable_tests="${TESTS}"     \
    -Dwith_vapi="${VALA_API}"     \
    -Denable_gtk_doc="${GTK_DOC}" \
    .. || exit 1

ninja || exit 1

# для запуска тестов устанавливаем переменную TESTS выше в 'true'
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GObject and GTK+ APIs for special graphical effects)
#
# libdazzle is a companion library to GObject and GTK+ that adds APIs for
# special graphical effects
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/libdazzle/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
