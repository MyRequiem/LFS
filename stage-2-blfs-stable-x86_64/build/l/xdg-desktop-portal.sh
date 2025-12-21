#! /bin/bash

PRGNAME="xdg-desktop-portal"

### xdg-desktop-portal (XDG portal frontend service)
# Служба на основе D-Bus, которая позволяет изолированным приложениям (таким
# как Flatpak и Snap) безопасно взаимодействовать с настольной средой и
# получать доступ к её функциям, например, к диалогу выбора файлов, скриншотам
# обмену экраном и т.д.

# Required:    fuse3
#              gdk-pixbuf
#              json-glib
#              pipewire
#              --- runtime ---
#              dbus
#              xdg-desktop-portal-gtk           (runtime для GNOME)
#              xdg-desktop-portal-gnome         (runtime для GNOME)
#              xdg-desktop-portal-lxqt          (runtime для LXQt)
# Recommended: bubblewrap
#              python3-docutils                 (для создания man-страниц)
# Optional:    geoclue
#              python3-pytest
#              libportal
#              --- для тестов ---
#              python3-dbusmock
#              umockdev
#              --- для документации ---
#              python3-sphinx
#              python3-sphinxext-opengraph      (https://pypi.org/project/sphinxext-opengraph/)
#              python3-sphinx-copybutton        (https://pypi.org/project/sphinx-copybutton/)
#              python3-furo                     (https://pypi.org/project/furo/)
#              flatpak                          (https://github.com/flatpak/flatpak)

###
# Конфиги
###
#    /etc/xdg-desktop-portal/portals.conf
#    /usr/share/xdg-desktop-portal/portals.conf
#    ~/.config/xdg-desktop-portal/portals.conf

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
    -D tests=disabled   \
    .. || exit 1

ninja || exit 1

# тесты
# meson configure -D tests=enabled &&
# ninja test

DESTDIR="${TMP_DIR}" ninja install

# Удалим файлы systemd, которые в нашей системе бесполезны
rm -rf "${TMP_DIR}/usr/lib/systemd"

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (XDG portal frontend service)
#
# xdg-desktop-portal is a D-Bus service that allows applications to interact
# with the desktop in a safe way. Several aspects of desktop interaction, like
# file chooser, desktop style, etc are implemented in different D-Bus APIs,
# known as portals. Sandboxed applications benefit the most from this service
# since they don't need special permissions to use the portal APIs, but any
# application can use it. xdg-desktop-portal safeguards many resources and
# features with a user-controlled permission system. This service needs a
# backend implementing desktop-specific portal interfaces.
#
# Home page: https://github.com/flatpak/${PRGNAME}/
# Download:  https://github.com/flatpak/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
