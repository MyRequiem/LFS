#! /bin/bash

PRGNAME="gnome-shell"

### GNOME Shell (GNOME Shell)
# Графическая оболочка и пользовательский интерфейс среды рабочего стола GNOME,
# которая обеспечивает взаимодействие пользователя с системой, включая запуск
# приложений, переключение между окнами и управление виртуальными рабочими
# столами. Это основная часть GNOME 3 и выше, заменяющая более ранние
# компоненты, такие как GNOME Panel

# Required:    evolution-data-server
#              gcr4
#              gjs
#              gnome-desktop
#              ibus
#              mutter
#              polkit
#              startup-notification
#              --- runtime ---
#              adwaita-icon-theme
#              dconf
#              elogind
#              gdm
#              gnome-control-center
#              libgweather
# Recommended: desktop-file-utils
#              gnome-autoar
#              gnome-bluetooth
#              gst-plugins-base
#              networkmanager
#              power-profiles-daemon
#              --- runtime ---
#              blocaled
#              gnome-menus
# Optional:    gtk-doc
#              bash-completion              (https://github.com/scop/bash-completion)

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
    -D systemd=false    \
    -D tests=false      \
    .. || exit 1

ninja || exit 1
# тесты проводятся в графической среде
# meson configure -D tests=true && ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Shell)
#
# The GNOME Shell is the core user interface of the GNOME Desktop Environment
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
