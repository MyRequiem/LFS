#! /bin/bash

PRGNAME="gnome-calculator"

### GNOME Calculator (GNOME Calculator)
# Стандартное, мощное приложение-калькулятор для среды рабочего стола GNOME,
# которое предлагает не только базовые арифметические операции, но и
# продвинутые режимы: научный (логарифмы, тригонометрия, комплексные числа),
# финансовый (проценты, амортизация) и режим программиста (системы счисления,
# булева алгебра), обеспечивая высокую точность вычислений.

# Required:    gtksourceview5
#              itstool
#              libadwaita
#              libgee
#              libsoup3
# Recommended: vala
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Calculator)
#
# GNOME Calculator is a powerful graphical calculator with financial, logical
# and scientific modes. It uses a multiple precision package to do its
# arithmetic to give a high degree of accuracy
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
