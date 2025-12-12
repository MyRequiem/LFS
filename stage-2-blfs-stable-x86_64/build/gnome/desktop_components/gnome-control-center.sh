#! /bin/bash

PRGNAME="gnome-control-center"

### GNOME Control Center (GNOME Control Center)
# Графический интерфейс для управления различными настройками среды рабочего
# стола GNOME, позволяющий пользователям легко настраивать операционную
# систему. Предоставляет набор утилит для конфигурирования системы, таких как
# управление внешним видом, сетевыми подключениями, устройствами и
# пользователями, а при запуске без аргументов отображает обзор всех доступных
# панелей настроек.

# Required:    accountsservice
#              colord-gtk
#              cups
#              gnome-bluetooth
#              gnome-online-accounts
#              gnome-settings-daemon
#              gsound
#              libadwaita
#              libgtop
#              libnma
#              libpwquality
#              mit-kerberos-v5
#              modemmanager
#              samba
#              shared-mime-info
#              tecla
#              udisks
# Recommended: ibus
#              blocaled                     (runtime)
# Optional:    --- для тестов ---
#              xorg-server                  (утилита Xvfb)
#              python3-dbusmock             (both for tests)
#              --- runtime ---
#              cups-pk-helper               (панель для принтеров)
#              gnome-color-manager          (цветовая панель)
#              gnome-shell                  (панель приложений)
#              sound-theme-freedesktop      (панель звуковых эффектов)

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
# GTK_A11Y=none ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Control Center)
#
# The GNOME Control Center package contains the GNOME settings manager
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
