#! /bin/bash

PRGNAME="gnome-settings-daemon"

### GNOME Settings Daemon (GNOME Settings Daemon)
# Фоновая служба (демон) в среде рабочего стола GNOME, которая управляет общими
# настройками сеанса, такими как темы оформления, шрифты, раскладки клавиатуры
# и другие системные параметры, и делает их доступными для приложений.
# Запускается при входе пользователя и обеспечивает корректную работу
# пользовательского интерфейса.

# Required:    alsa-lib
#              fontconfig
#              gcr4
#              geoclue
#              geocode-glib
#              gnome-desktop
#              libcanberra
#              libgweather
#              libnotify
#              libwacom
#              pulseaudio
#              upower
# Recommended: colord
#              cups
#              networkmanager
#              modemmanager
#              nss
#              wayland
#              blocaled                    (runtime)
# Optional:    gnome-session
#              mutter
#              --- для тестов ---
#              python3-dbusmock
#              umockdev
#              xorg-server или xwayland    (утилита Xvfb для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим обнаружение libelogind для тестов
sed -e 's/libsystemd/libelogind/' -i plugins/power/test.py || exit 1

# fix backlight functionality in gnome-control-center
sed -e 's/(backlight->logind_proxy)/(0)/' -i \
    plugins/power/gsd-backlight.c || exit 1

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D systemd=false    \
    .. || exit 1

ninja || exit 1
# env -u GALLIUM_DRIVERS ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Settings Daemon)
#
# The GNOME Settings Daemon is responsible for setting various parameters of a
# GNOME Session and the applications that run under it
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
