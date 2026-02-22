#! /bin/bash

PRGNAME="plasma"
PKG_VERSION="6.4.4"

### KDE Plasma (KDE Display Environment)
# Набор библиотек, основанных на Qt6 и QML

# Required:    boost
#              ffmpeg
#              gtk+3
#              kde-frameworks
#              kirigami-addons
#              libdisplay-info
#              libpwquality
#              libqalculate
#              libnl
#              libxcvt
#              libxkbcommon
#              mesa                             (собранный с пакетом 'wayland')
#              opencv
#              phonon
#              pipewire
#              pulseaudio-qt
#              qca
#              qcoro
#              sassc
#              taglib
#              xdotool
#              xorg-evdev-driver
# Recommended: gsettings-desktop-schemas
#              libcanberra
#              libinput
#              libpcap
#              libwacom и xorg-wacom-driver     (для планшетов Wacom)
#              linux-pam
#              lm-sensors
#              oxygen-icons
#              pciutils
#              power-profiles-daemon
#              python3-psutil
#              python3-pygdbmi
#              python3-sentry-sdk
#              python3-urllib3
#              --- runtime ---
#              accountsservice
#              breeze-icons
#              kio-extras
#              smartmontools
#              xdg-desktop-portal
#              xwayland
# Optional:    appstream                        (собранный с параметром -D qt=true)
#              glu
#              ibus
#              qtwebengine
#              kdevplatform                     (https://www.kdevelop.org/)
#              libgps                           (https://gpsd.gitlab.io/gpsd/)
#              libhybris                        (https://github.com/libhybris/libhybris)
#              packagekit-qt                    (https://www.freedesktop.org/software/PackageKit/releases/)
#              qapt                             (https://launchpad.net/qapt)
#              scim                             (https://github.com/osiam/osiam)
#              socat                            (для pam_kwallet) http://www.dest-unreach.org/socat/

ROOT="/root/src/lfs"
SOURCES="${ROOT}/src"

source "${ROOT}/check_environment.sh" || exit 1

TMP="/tmp/build-${PRGNAME}-${PKG_VERSION}"
rm -rf "${TMP}"

# директория для сборки всего пакета
TMP_PACKAGE="${TMP}/package-${PRGNAME}-${PKG_VERSION}"
mkdir -pv "${TMP_PACKAGE}/etc/pam.d"

# директория для распаковки исходников
TMP_SRC="${TMP}/src"
mkdir -pv "${TMP_SRC}"

# директория для установки пакетов по отдельности
TMP_PKGS="${TMP}/pkgs"
mkdir -p "${TMP_PKGS}"

# В итоге дерево сборки выглядит так
# /tmp
#     |
#     build-plasma-x.x.x/           ${TMP}
#         |
#         package-plasma-x.x.x/     ${TMP_PACKAGE}
#         pkgs/                     ${TMP_PKGS}
#         src/                      ${TMP_SRC}

# список всех пакетов
PACKAGES="\
kdecoration
libkscreen
libksysguard
breeze
breeze-gtk
layer-shell-qt
libplasma
kscreenlocker
kinfocenter
kglobalacceld
kwayland
aurorae
kwin-x11
kwin
plasma5support
kpipewire
plasma-workspace
plasma-disks
bluedevil
kde-gtk-config
kmenuedit
kscreen
kwallet-pam
kwrited
milou
plasma-nm
plasma-pa
plasma-workspace-wallpapers
polkit-kde-agent-1
powerdevil
plasma-desktop
kgamma
ksshaskpass
sddm-kcm
kactivitymanagerd
plasma-integration
xdg-desktop-portal-kde
drkonqi
plasma-vault
kde-cli-tools
systemsettings
plasma-thunderbolt
plasma-firewall
plasma-systemmonitor
qqc2-breeze-style
ksystemstats
oxygen-sounds
kdeplasma-addons
plasma-welcome
ocean-sound-theme
print-manager
oxygen
spectacle
"

show_error() {
    echo -e "\n***"
    echo "* Error: $1"
    echo "***"
}

get_pkg_version() {
    # $1 - имя пакета, версию которого нужно найти
    local TARBOL_VERSION
    TARBOL_VERSION="$(find "${SOURCES}" -type f \
        -name "${1}-[0-9]*.tar.?z*" 2>/dev/null | sort | \
        head -n 1 | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

    echo "${TARBOL_VERSION}"
}

for PKGNAME in ${PACKAGES}; do
    echo -e "\n***************** Building ${PKGNAME} package *****************"
    sleep 1

    # определяем версию пакета
    VERSION="$(get_pkg_version "${PKGNAME}")"

    # версия не найдена
    if [ -z "${VERSION}" ]; then
        show_error "Version for '${PKGNAME}' package not found in ${SOURCES}"
        exit 1
    fi

    # распаковываем архив
    cd "${TMP_SRC}" || exit 1
    echo "Unpacking ${PKGNAME}-${VERSION} source archive..."
    tar xvf "${SOURCES}/${PKGNAME}-${VERSION}".tar.?z* &>/dev/null || {
        show_error "Can not unpack ${PKGNAME}-${VERSION} archive"
        exit 1
    }

    cd "${PKGNAME}-${VERSION}" || exit 1

    chown -R root:root .
    find -L . \
        \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
        -o -perm 511 \) -exec chmod 755 {} \; -o \
        \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
        -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

    # конфигурация
    mkdir build
    cd build || exit 1

    cmake                                   \
        -D CMAKE_INSTALL_PREFIX=/usr        \
        -D CMAKE_INSTALL_LIBEXECDIR=libexec \
        -D CMAKE_BUILD_TYPE=Release         \
        -D BUILD_QT5=OFF                    \
        -D BUILD_TESTING=OFF                \
        -D BUILD_KCM_TABLET=OFF             \
        -W no-dev .. || {
            show_error "'cmake' for ${PKGNAME} package"
            exit 1
        }

    # сборка
    make || {
        show_error "'make' for ${PKGNAME} package"
        exit 1
    }

    # установка
    PKG_INSTALL_DIR="${TMP_PKGS}/package-${PKGNAME}-${VERSION}"
    mkdir -pv "${PKG_INSTALL_DIR}/var/log/packages"

    make install DESTDIR="${PKG_INSTALL_DIR}" || {
        show_error "'make install' for ${PKGNAME} package"
        exit 1
    }

    # удалим бесполезные systemd модули и документацию
    rm -rf "${PKG_INSTALL_DIR}/usr/lib/systemd"
    rm -rf "${PKG_INSTALL_DIR}/usr/share/doc"

    # stripping
    BINARY="$(find "${PKG_INSTALL_DIR}" -type f -print0 | \
        xargs -0 file 2>/dev/null | grep -e "executable" -e "shared object" | \
        grep ELF | cut -f 1 -d :)"

    for BIN in ${BINARY}; do
        strip --strip-unneeded "${BIN}"
    done

    # обновляем базу данных info (/usr/share/info/dir)
    INFO="/usr/share/info"
    if [ -d "${PKG_INSTALL_DIR}${INFO}" ]; then
        cd "${PKG_INSTALL_DIR}${INFO}" || exit 1
        # оставляем только *info* файлы
        find . -type f ! -name "*info*" -delete
        for FILE in *; do
            install-info --dir-file="${INFO}/dir" "${FILE}" 2>/dev/null
        done
    fi

    # имя пакета в нижний регистр
    PKGNAME="$(echo "${PKGNAME}" | tr '[:upper:]' '[:lower:]')"

    # пишем в ${PKG_INSTALL_DIR}/var/log/packages/${PKGNAME}-${VERSION}
    (
        cd "${PKG_INSTALL_DIR}" || exit 1

        LOG="var/log/packages/${PKGNAME}-${VERSION}"
        cat << EOF > "${LOG}"
# Package: ${PKGNAME}
#
###
# This package is part of '${PRGNAME}' package
###
#
EOF
        find . | cut -d . -f 2- | sort >> "${LOG}"
        # удалим пустые строки в файле
        sed -i '/^$/d' "${LOG}"
        # комментируем все пути
        sed -i 's/^\//# \//g' "${LOG}"
    )

    # копируем собранный пакет в директорию основного пакета и в корень системы
    /bin/cp -vpR "${PKG_INSTALL_DIR}"/* "${TMP_PACKAGE}"/
    /bin/cp -vpR "${PKG_INSTALL_DIR}"/* /

    # для сборки следующих пакетов, которые могут быть зависимы от текущего,
    # нужно найти установленные библиотеки текущего пакета и кэшировать их в
    # /etc/ld.so.cache
    /sbin/ldconfig
done

###
# Конфигурация Linux PAM
###

PAM_D_KDE="/etc/pam.d/kde"
cat << EOF > "${PAM_D_KDE}"
auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     include        system-auth

account  include        system-account
password include        system-password
session  include        system-session

EOF
cp "${PAM_D_KDE}" "${TMP_PACKAGE}/etc/pam.d/"

KDE_NP="/etc/pam.d/kde-np"
cat << EOF > "${KDE_NP}"
auth     requisite      pam_nologin.so
auth     required       pam_env.so

auth     required       pam_succeed_if.so uid >= 1000 quiet
auth     required       pam_permit.so

account  include        system-account
password include        system-password
session  include        system-session

EOF
cp "${KDE_NP}" "${TMP_PACKAGE}/etc/pam.d/"

KSCREENSAVER="/etc/pam.d/kscreensaver"
cat << EOF > "${KSCREENSAVER}"
auth    include system-auth
account include system-account

EOF
cp "${KSCREENSAVER}" "${TMP_PACKAGE}/etc/pam.d/"

cat << EOF > "/var/log/packages/${PRGNAME}-${PKG_VERSION}"
# Package: ${PRGNAME} (KDE Display Environment)
#
# KDE Plasma is a collection of packages based on top of KDE Frameworks and
# QML. They implement the KDE Display Environment (Plasma)
#
# Home page: https://download.kde.org/stable/${PRGNAME}/
# Download:  https://download.kde.org/stable/${PRGNAME}/${VERSION}
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_PACKAGE}" "${PRGNAME}-${PKG_VERSION}"
