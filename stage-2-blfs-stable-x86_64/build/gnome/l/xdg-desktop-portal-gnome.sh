#! /bin/bash

PRGNAME="xdg-desktop-portal-gnome"

### xdg-desktop-portal-gnome (GNOME's xdg-desktop-portal Backend)
# Реализация портала рабочего стола GNOME, которая позволяет приложениям,
# работающим в изолированных средах (например, Flatpak), безопасно
# взаимодействовать с системными ресурсами, такими как файловая система,
# камера, звуковой сервер и т.д.

# Required:    gnome-desktop
#              gtk4
#              libadwaita
#              xdg-desktop-portal
#              xdg-desktop-portal-gtk    (runtime)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                    \
    --prefix=/usr              \
    --buildtype=release        \
    -D systemduserunitdir=/tmp \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

# удалим файлы systemd, которые в нашей системе бесполезны
rm -rf "${TMP_DIR}/tmp"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# обновим /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME's xdg-desktop-portal Backend)
#
# xdg-desktop-portal-gnome is a backend for xdg-desktop-portal, that is using
# GTK and various pieces of GNOME infrastructure
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
