#! /bin/bash

PRGNAME="rxvt-unicode"

### rxvt-unicode (enhanced version of rxvt terminal emulator)
# Современная версия легендарного терминала rxvt, которая потребляет крошечное
# количество памяти, но при этом отлично работает с любыми языками и сложными
# шрифтами, поддерживает XFT (использование FreeType для отображения шрифтов с
# применением расширения X Rendering Extention - XRender), Unicode и Perl
# расширения.

# Required:    libptytty
#              Graphical Environments
# Recommended: no
# Optional:    gdk-pixbuf               (для возможности уставливать фоновые изображения)
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
TERMINFO_DIR="/usr/share/terminfo"
mkdir -p "${TMP_DIR}"{${ETC_APP_DEFAULTS},${APPLICATIONS},${TERMINFO_DIR}}

# меняем Hotkey для запуска плагина searchable-scrollback (поиск) с M-s на M-z
sed -e 's/M-s/M-z/g' -i src/perl/searchable-scrollback || exit 1

# Когда приложение внутри терминала (например, тема оформления в Vim или сам
# tmux) хочет узнать текущий цвет фона или текста, оно посылает запрос (OSC
# последовательность). URxvt должен ответить, какой цвет установлен и ответ
# должен заканчиваться специальным символом-терминатором: либо коротким BEL
# (звуковой сигнал, \a), либо длинным ST (String Terminator, ESC \). Без
# sed-патча: URxvt пытается ответить тем же символом, который пришел в запросе.
# Но он делает это некорректно, если запрос был «длинным» (7-битным). С патчем:
# urxvt принудительно всегда отвечает через ESC \. Это «железобетонный» способ,
# который понимают все современные программы.
#
###
# Две команды sed ниже - это моя переделка оригинального патча от Патрика
# (Patrick J. Volkerding, Slackware)
###
# Index: src/command.C
# --- src/command.C.orig
# +++ src/command.C
# @@ -3426,9 +3426,9 @@ rxvt_term::process_color_seq (int report, int color, c
#          snprintf (rgba_str, sizeof (rgba_str), "rgb:%04x/%04x/%04x", c.r, c.g, c.b);
#
#        if (IN_RANGE_INC (color, minCOLOR, maxTermCOLOR))
# -        tt_printf ("\033]%d;%d;%s%c", report, color - minCOLOR, rgba_str, resp);
# +        tt_printf ("\033]%d;%d;%s\033\\", report, color - minCOLOR, rgba_str);
#        else
# -        tt_printf ("\033]%d;%s%c", report, rgba_str, resp);
# +        tt_printf ("\033]%d;%s\033\\", report, rgba_str, resp);
#      }
#    else
#      set_window_color (color, str);
#
sed -i 's/%s%c"\(.*minCOLOR.*\), resp/%s%c"\1/' src/command.C || exit 1
sed -i 's/%s%c"\(.*rgba_str\)/%s\\033\\\\"\1/'  src/command.C || exit 1

export TERMINFO="${TMP_DIR}${TERMINFO_DIR}"
./configure                       \
    --prefix=/usr                 \
    --sysconfdir=/etc             \
    --localstatedir=/var          \
    --enable-everything           \
    --enable-256-color            \
    --enable-unicode3             \
    --enable-combining            \
    --enable-xft                  \
    --enable-font-styles          \
    --enable-pixbuf               \
    --enable-startup-notification \
    --enable-transparency         \
    --enable-fading               \
    --enable-rxvt-scroll          \
    --enable-next-scroll          \
    --enable-xterm-scroll         \
    --enable-perl                 \
    --enable-xim                  \
    --enable-iso14755             \
    --enable-frills               \
    --enable-keepscrolling        \
    --enable-selectionscrolling   \
    --enable-mousewheel           \
    --enable-slipwheeling         \
    --enable-smart-resize         \
    --enable-text-blink           \
    --enable-pointer-blank        \
    --with-codesets=all           \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

cat << EOF > "${TMP_DIR}${ETC_APP_DEFAULTS}/URxvt"
#define MAIN_FONT xft:Liberation Mono:size=10:antialias=true

URxvt.background: black
URxvt.foreground: white
URxvt.cursorBlink: true
URxvt.cursorUnderline:true
URxvt.scrollBar: false
URxvt.font: MAIN_FONT
URxvt.boldFont: MAIN_FONT
! Fix input prompt centering glitch on startup (bug introduced in
! rxvt-unicode-9.31). Setting a negative height (-1) disables rigid grid
! initialization, forcing the window manager to dynamically size the window
! and properly anchor the prompt to the top.
URxvt.geometry: 80x-1
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
StartupNotify=true
Keywords=console;command line;execute;
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

update-desktop-database -q

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (enhanced version of rxvt terminal emulator)
#
# This project is an enhanced version of the rxvt terminal emulator. It has
# full unicode and Xft support, does font antialiasing and italics, and has the
# same transparency capabilities as ATerm. It can be extended using Perl.
#
# Home page: https://github.com/exg/${PRGNAME}
# Download:  https://dist.schmorp.de/${PRGNAME}/Attic/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
