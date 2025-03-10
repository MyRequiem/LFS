#! /bin/bash

PRGNAME="adwaita-icon-theme"

### Adwaita Icon Theme (default icons used by GTK+)
# Тема иконок для GTK+ приложений

# Required:    no
# Recommended: no
# Optional:    git
#              gtk+2
#              gtk+3
#              librsvg
#              inkscape
#              icon-tools (https://launchpad.net/icontool/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# если установлен librsvg и gtk+2 и/или gtk+3 создадим/обновим
# /usr/share/icons/Adwaita/icon-theme.cache
command -v rsvg-convert &>/dev/null && \
    command -v gtk-update-icon-cache &>/dev/null && \
        echo "gtk-update-icon-cache ..." && \
            gtk-update-icon-cache /usr/share/icons/Adwaita/

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
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
