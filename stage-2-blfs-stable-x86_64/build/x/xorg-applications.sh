#! /bin/bash

PRGNAME="xorg-applications"
PKG_VERSION="7"

### Xorg Applications (Xorg Applications)
# Основные приложения поставляемые с Xorg

# Required:    libpng
#              mesa
#              xbitmaps
#              xcb-util
# Recommended: no
# Optional:    linux-pam
#              cairo-5c  (https://www.cairographics.org/releases/)
#              nickle    (только для запуска не документированного скрипта xkeyhost) http://nickle.org/

###
# NOTES:
###
# iceauth         - is the ICE authority file utility
# luit            - provides locale and ISO 2022 support for Unicode terminals
# mkfontdir       - creates an index of X font files in a directory
# mkfontscale     - creates an index of scalable font files for X
# sessreg         - manages utmp/wtmp entries for non-init clients
# setxkbmap       - sets the keyboard using the X Keyboard Extension
# smproxy         - is the Session Manager Proxy
# x11perf         - is an X11 server performance test program
# x11perfcomp     - is an X11 server performance comparison program
# xauth           - is the X authority file utility
# xbacklight      - adjusts backlight brightness using RandR extension
# xcmsdb          - is the Device Color Characterization utility for the X Color Management System
# xcursorgen      - creates an X cursor file from a collection of PNG images
# xdpr            - dumps an X window directly to a printer
# xdpyinfo        - is a display information utility for X
# xdriinfo        - queries configuration information of DRI drivers
# xev             - prints contents of X events
# xgamma          - alters a monitors gamma correction through the X server
# xhost           - is a server access control program for X
# xinput          - is a utility to configure and test X input devices
# xkbbell         - is an XKB utility program that raises a bell event
# xkbcomp         - compiles an XKB keyboard description
# xkbevd          - is the XKB event daemon
# xkbvleds        - shows the XKB status of keyboard LEDs
# xkbwatch        - monitors modifier keys and LEDs
# xlsatoms        - lists interned atoms defined on the server
# xlsclients      - lists client applications running on a display
# xmessage        - displays a message or query in a window
# xmodmap         - is a utility for modifying keymaps and pointer button mappings in X
# xpr             - prints an X window dump
# xprop           - is a property displayer for X
# xrandr          - is a primitive command line interface to RandR extension
# xrdb            - is the X server resource database utility
# xrefresh        - refreshes all or part of an X screen
# xset            - is the user preference utility for X
# xsetroot        - is the root window parameter setting utility for X
# xvinfo          - prints out X-Video extension adaptor information
# xwd             - dumps an image of an X window
# xwininfo        - is a window information utility for X
# xwud            - is an image displayer for X
# appres          - list X application resource database
# bitmap          - XBM format bitmap editor and converter utilities
# fonttosfnt      - wrap a bitmap font in a sfnt (TrueType) wrapper
# fslsfonts       - list fonts served by X font server
# fstobdf         - generate BDF font from X font server
# listres         - list resources in widgets
# mkcomposecache  - creates global (system-wide) Compose cache files
# rendercheck     - test X11 Render support
# rgb             - X colorname -> RGB mapping database
# transset        - utility for setting opacity property
# xcalc           - scientific calculator for X
# xclipboard      - X clipboard manager
# xconsole        - monitor system console messages with X
# xdbedizzy       - DBE (Double Buffer Extension) sample
# xditview        - display ditroff output
# xfd             - display all the characters in an X font
# xfontsel        - point and click selection of X11 font names
# xkbprint        - print an XKB keyboard description
# xlsfonts        - list X fonts available on X server
# xmag            - magnify parts of the screen
# xscope          - program to monitor X11/Client conversations
# xsm             - X Session Manager
# xstdcmap        - X standard colormap utility
# xvidtune        - video mode tuner for Xorg

ROOT="/root/src/lfs"
SOURCES="${ROOT}/src"

source "${ROOT}/check_environment.sh" || exit 1
source "${ROOT}/xorg_config.sh"       || exit 1

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

TMP="/tmp/build-${PRGNAME}-${PKG_VERSION}"
rm -rf "${TMP}"

# директория для сборки всего пакета
TMP_PACKAGE="${TMP}/package-${PRGNAME}-${PKG_VERSION}"
mkdir -pv "${TMP_PACKAGE}"

# директория для распаковки исходников
TMP_SRC="${TMP}/src"
mkdir -pv "${TMP_SRC}"

# директория для установки пакетов по отдельности
TMP_PKGS="${TMP}/pkgs"
mkdir -p "${TMP_PKGS}"

# список всех пакетов
PACKAGES="\
iceauth \
luit \
mkfontdir \
mkfontscale \
sessreg \
setxkbmap \
smproxy \
x11perf \
xauth \
xbacklight \
xcmsdb \
xcursorgen \
xdpyinfo \
xdriinfo \
xev \
xgamma \
xhost \
xinput \
xkbcomp \
xkbevd \
xkbutils \
xlsatoms \
xlsclients \
xmessage \
xmodmap \
xpr \
xprop \
xrandr \
xrdb \
xrefresh \
xset \
xsetroot \
xvinfo \
xwd \
xwininfo \
xwud \
bdftopcf \
appres \
bitmap \
fonttosfnt \
fslsfonts \
fstobdf \
listres \
mkcomposecache \
rendercheck \
rgb \
transset \
xcalc \
xclipboard \
xconsole \
xdbedizzy \
xditview \
xfd \
xfontsel \
xkbprint \
xlsfonts \
xmag \
xscope \
xsm \
xstdcmap \
xvidtune \
"

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

    case "${PKGNAME}" in
        luit)
            sed -i -e "/D_XOPEN/s/5/6/" configure || {
                show_error "'sed' for ${PKGNAME} package"
                exit 1
            }
            ;;
    esac

    # shellcheck disable=SC2086
    ./configure        \
        ${XORG_CONFIG} || exit 1

    # сборка
    make || {
        show_error "'make' for ${PKGNAME} package"
        exit 1
    }

    # директория для установки собранного пакета
    PKG_INSTALL_DIR="${TMP_PKGS}/package-${PKGNAME}-${VERSION}"
    mkdir -pv "${PKG_INSTALL_DIR}/var/log/packages"

    make install DESTDIR="${PKG_INSTALL_DIR}" || {
        show_error "'make install' for ${PKGNAME} package"
        exit 1
    }

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
done

cat << EOF > "/var/log/packages/${PRGNAME}-${PKG_VERSION}"
# Package: ${PRGNAME} (Xorg Applications)
#
# The Xorg applications provide the expected applications available in previous
# X Window implementations.
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/app/
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_PACKAGE}" "${PRGNAME}-${PKG_VERSION}"
