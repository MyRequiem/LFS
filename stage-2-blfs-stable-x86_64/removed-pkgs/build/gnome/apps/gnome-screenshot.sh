#! /bin/bash

PRGNAME="gnome-screenshot"

### GNOME Screenshot (GNOME Screenshot)
# Стандартная программа для создания снимков экрана в среде рабочего стола
# GNOME, позволяющая захватывать весь экран, отдельное окно или выделенную
# область, с возможностью задержки, добавления декоративных рамок и сохранения
# в файл или буфер обмена

# Required:    gtk+3
#              libcanberra
#              libhandy
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим сборку с новыми версиями meson
sed -i '/merge_file/{n;d}' data/meson.build || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Screenshot)
#
# The GNOME Screenshot is a utility used for taking screenshots of the entire
# screen, a window or a user-defined area of the screen, with optional
# beautifying border effects
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
