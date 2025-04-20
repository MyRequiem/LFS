#! /bin/bash

PRGNAME="vala"

### Vala (Compiler for the GObject type system)
# Язык программирования, предназначенный для прикладного и системного
# программирования на основе библиотек GLib Object System (GObject) рабочей
# среды GNOME/GTK+

# Required:    glib
# Recommended: graphviz   (для сборки утилиты 'valadoc')
# Optional:    dbus       (для тестов)
#              libxslt    (для документации)
#              help2man   (https://www.gnu.org/software/help2man/)
#              jing       (https://github.com/relaxng/jing-trang)
#              weasyprint (https://weasyprint.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-valadoc || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Compiler for the GObject type system)
#
# Vala is a new programming language that aims to bring modern programming
# language features to GNOME developers without imposing any additional runtime
# requirements and without using a different ABI compared to applications and
# libraries written in C
#
# Home page: https://wiki.gnome.org/Projects/Vala
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
