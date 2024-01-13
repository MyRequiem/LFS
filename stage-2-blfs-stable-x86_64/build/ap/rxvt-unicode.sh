#! /bin/bash

PRGNAME="rxvt-unicode"

### rxvt-unicode (enhanced version of rxvt terminal emulator)
# Клон эмулятора терминала rxvt с поддержкой XFT, Unicode и Perl расширениями

# Required:    Graphical Environments
# Recommended: no
# Optional:    gdk-pixbuf
#              startup-notification

### Конфигурация
#    /etc/X11/app-defaults/URxvt
#    ~/.Xresources или ~/.Xdefaults
#
# Перечитать файл и сохранить старые ресурсы: $ xrdb -merge ~/.Xresources
# Перечитать и удалить старые ресурсы:        $ xrdb ~/.Xresources
# Просмотр текущих загруженных ресурсов:      $ xrdb -query -all

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
ETC_APP_DEFAULTS="/etc/X11/app-defaults"
APPLICATIONS="/usr/share/applications"
mkdir -pv "${TMP_DIR}"{${ETC_APP_DEFAULTS},${APPLICATIONS}}

# меняем горячие клавиши для запуска плагина поиска (searchable-scrollback) с
# M-s на M-z
sed -e 's/M-s/M-z/g' -i src/perl/searchable-scrollback || exit 1

./configure                        \
    --prefix=/usr                  \
    --sysconfdir=/etc              \
    --localstatedir=/var           \
    --enable-everything            \
    --enable-256-color             \
    --enable-unicode3              \
    --enable-combining             \
    --enable-xft                   \
    --enable-font-styles           \
    --enable-pixbuf                \
    --disable-startup-notification \
    --enable-transparency          \
    --enable-fading                \
    --enable-rxvt-scroll           \
    --enable-next-scroll           \
    --enable-xterm-scroll          \
    --enable-perl                  \
    --enable-xim                   \
    --enable-iso14755              \
    --enable-frills                \
    --enable-keepscrolling         \
    --enable-selectionscrolling    \
    --enable-mousewheel            \
    --enable-slipwheeling          \
    --enable-smart-resize          \
    --enable-text-blink            \
    --enable-pointer-blank         \
    --enable-utmp                  \
    --enable-wtmp                  \
    --enable-lastlog || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

### устанавливаем расширение clipboard, не входящее в состав rxvt-unicode
PLUGIN_PATH="/usr/lib/urxvt/perl"
cp "${SOURCES}/clipboard" "${TMP_DIR}${PLUGIN_PATH}/"
chown root:root           "${TMP_DIR}${PLUGIN_PATH}/clipboard"
chmod 644                 "${TMP_DIR}${PLUGIN_PATH}/clipboard"

cat << EOF > "${TMP_DIR}${ETC_APP_DEFAULTS}/URxvt"
! ------------
! $ man urxvt
! ------------

! Use the specified colour as the windows background colour [default white]
URxvt*background: black

! Use the specified colour as the windows foreground colour [default black]
URxvt*foreground: yellow

! Select the fonts to be used. This is a comma separated list of font names
URxvt*font: xft:Monospace:pixelsize=18

! Comma-separated list(s) of perl extension scripts (default: "default")
URxvt*perl-ext: matcher

! Specifies the program to be started with a URL argument. Used by
URxvt*url-launcher: firefox

! When clicked with the mouse button specified in the "matcher.button" resource
! (default 2, or middle), the program specified in the "matcher.launcher"
! resource (default, the "url-launcher" resource, "sensible-browser") will be
! started with the matched text as first argument.
! Below, default modified to mouse left button.
URxvt*matcher.button: 1
EOF

cat << EOF > "${TMP_DIR}${APPLICATIONS}/urxvt.desktop"
[Desktop Entry]
Encoding=UTF-8
Name=Rxvt-Unicode Terminal
Comment=Use the command line
GenericName=Terminal
Exec=urxvt
Terminal=false
Type=Application
Icon=utilities-terminal
Categories=GTK;Utility;TerminalEmulator;
StartupNotify=false
Keywords=console;command line;execute;
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

update-desktop-database -q

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (enhanced version of rxvt terminal emulator)
#
# This project is an enhanced version of the rxvt terminal emulator. It has
# full unicode and Xft support, does font antialiasing and italics, and has the
# same transparency capabilities as ATerm. It can be extended using Perl.
#
# Home page: https://software.schmorp.de/pkg/${PRGNAME}/
# Download:  https://ftp.osuosl.org/pub/blfs/conglomeration/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
