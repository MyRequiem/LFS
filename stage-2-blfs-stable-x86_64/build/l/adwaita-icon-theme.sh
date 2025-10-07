#! /bin/bash

PRGNAME="adwaita-icon-theme"

### Adwaita Icon Theme (default icons used by GTK+)
# Тема иконок для GTK+ приложений

# Required:    gtk+3 или gtk4
#              librsvg
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup       \
    --prefix=/usr \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов

# перед установкой удалим старые иконки
rm -rf /usr/share/icons/Adwaita/
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# создадим/обновим /usr/share/icons/Adwaita/icon-theme.cache
gtk-update-icon-cache /usr/share/icons/Adwaita/

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (default icons used by GTK+)
#
# The Adwaita Icon Theme package contains an icon theme for Gtk+3 applications
#
# Home page: https://gitlab.gnome.org/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
