#! /bin/bash

PRGNAME="i3"

### i3 (an improved dynamic tiling window manager)
# Тайловый оконный менеджер.

# Required:    libxcb
#              xcb-util
#              xcb-util-cursor
#              xcb-util-wm
#              xcb-util-keysyms
#              xcb-util-xrm
#              libev
#              libxkbcommon
#              libyajl
#              python3-asciidoc
#              xmlto
#              docbook-xml
#              pcre
#              startup-notification
#              pango
#              cairo
#              perl-anyevent-i3
#              dmenu
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}/txt"

mkdir build
cd build || exit 1

meson                       \
    --prefix=/usr           \
    -Dmans=true             \
    -Ddocs=true             \
    -Ddocdir="${DOCS}/html" \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

# документация
cd ../ || exit 1
cp -a DEPENDS LICENSE RELEASE-NOTES-* "${TMP_DIR}${DOCS}"
find docs/ -type f ! \(     \
        -name "*.conf" -o   \
        -name "*.asy"  -o   \
        -name "*.png"  -o   \
        -name "*.html" -o   \
        -name "*.css"  -o   \
        -name "*.svg"  -o   \
        -name "*.dia"  -o   \
        -name "i3-pod2html" \
    \) -exec cp {} "${TMP_DIR}${DOCS}/txt" \;

chown -R root:root "${TMP_DIR}${DOCS}"/*

CONFIG="/etc/i3/config"
cat << EOF > "${TMP_DIR}${CONFIG}"
# Start ${CONFIG}
#
# i3 config file (v4)
#
# Please see https://i3wm.org/docs/userguide.html for a complete reference!
#
# This config file uses keycodes (bindsym) and was written for the QWERTY
# layout.
#
# To get a config file with the same key positions, but for your current
# layout, use the i3-config-wizard
#

# Mod key = Win key
set \$mod Mod4

# font for window titles. will also be used by the bar unless a different font
# is used in the bar {} block below
font pango:Liberation Sans 10

# disable window titles
default_border pixel

# active window border thickness
for_window [tiling] border pixel 0

# floating windows
# \$mod+right mouse click - window resizing
# \$mod+left  mouse click - moving window
floating_modifier \$mod

# terminal
bindsym \$mod+Return exec --no-startup-id uxterm

# dmenu
# complete
bindsym \$mod+c exec --no-startup-id dmenu_run -i -l 15 -x 200 -y 100 -w 350 -fn "Liberation Mono-10"
# custom
bindsym \$mod+d exec --no-startup-id dmenu_short.sh
# passwords (password-store)
bindsym \$mod+Shift+p exec --no-startup-id dmenu_pass -p "Pass:" -l 15 -i -x 200 -y 100 -w 420 -fn "Liberation Mono-10"
# clipboard
bindsym \$mod+p exec --no-startup-id clipmenu -l 40 -i -x 200 -y 50 -w 500 -fn "Liberation Mono-10"

# imgur-screenshot
bindsym \$mod+x       exec --no-startup-id imgur-screenshot.sh --noupload --clear
bindsym \$mod+Shift+x exec --no-startup-id imgur-screenshot.sh --noupload

# windows
# kill current window
bindsym \$mod+Shift+c kill
# change window focus
bindsym \$mod+h focus left
bindsym \$mod+j focus down
bindsym \$mod+k focus up
bindsym \$mod+l focus right

# open next window split vertically/horizontally
bindsym \$mod+Shift+Right split v
bindsym \$mod+Shift+Down  split h

# full screen mode on/off
bindsym \$mod+t fullscreen toggle

# change window layout (stacked, tabbed, toggle split)
bindsym \$mod+s layout stacking
bindsym \$mod+w layout tabbed
bindsym \$mod+e layout toggle split

# tiling/floating for window
bindsym \$mod+a floating toggle

# window resizing
# enter window resizing mode
bindsym \$mod+r mode "resize"
# in resizing mode:
mode "resize" {
    bindsym l resize shrink width 1 px or 1 ppt
    bindsym h resize grow width 1 px or 1 ppt
    bindsym j resize shrink height 1 px or 1 ppt
    bindsym k resize grow height 1 px or 1 ppt
    # return to normal mode (<Enter>, <Escape> or \$mod+r)
    bindsym Return  mode "default"
    bindsym Escape  mode "default"
    bindsym \$mod+r mode "default"
}

# desktops
# define names for desktops
set \$ws1 "1"
set \$ws2 "2"
set \$ws3 "3"
set \$ws4 "4"
set \$ws5 "5"
set \$ws6 "6"
set \$ws7 "7"
set \$ws8 "8"
set \$ws9 "9"

# launch applications on a specific desktop
assign [class="^URxvt$"] \$ws1

# applications always opened in floating-mode
for_window [window_role="About"] floating enable
for_window [title="Authy"]       floating enable
for_window [class="^XTerm$"]     floating enable
for_window [class="^UXTerm$"]    floating enable

# changing desktops
bindsym \$mod+1 workspace number \$ws1
bindsym \$mod+2 workspace number \$ws2
bindsym \$mod+3 workspace number \$ws3
bindsym \$mod+4 workspace number \$ws4
bindsym \$mod+5 workspace number \$ws5
bindsym \$mod+6 workspace number \$ws6
bindsym \$mod+7 workspace number \$ws7
bindsym \$mod+8 workspace number \$ws8
bindsym \$mod+9 workspace number \$ws9

# moving windows to another desktop
bindsym \$mod+Shift+1 move container to workspace number \$ws1
bindsym \$mod+Shift+2 move container to workspace number \$ws2
bindsym \$mod+Shift+3 move container to workspace number \$ws3
bindsym \$mod+Shift+4 move container to workspace number \$ws4
bindsym \$mod+Shift+5 move container to workspace number \$ws5
bindsym \$mod+Shift+6 move container to workspace number \$ws6
bindsym \$mod+Shift+7 move container to workspace number \$ws7
bindsym \$mod+Shift+8 move container to workspace number \$ws8
bindsym \$mod+Shift+9 move container to workspace number \$ws9

# reload the configuration file
bindsym \$mod+Shift+f reload
# restart i3 inplace (preserves your layout/session, can be used to upgrade i3)
bindsym \$mod+Shift+r restart
# exit i3 (logs you out of your X session)
bindsym \$mod+Shift+q exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

# move current desktop to left/right screen (mod+Shift+</>)
bindsym \$mod+Shift+comma  move workspace to output left
bindsym \$mod+Shift+period move workspace to output right

# to desktop with terminal (desktop 1)
bindsym \$mod+i workspace 1

# switch all desktops forward/backward
bindsym \$mod+space       workspace next
bindsym \$mod+Shift+space workspace prev

# bumblebee-status
bar {
    id                  bar0
    mode                dock
    position            bottom
    tray_padding        0
    workspace_buttons   yes

    colors {
        background #262626
        statusline #FFFFFF
    }

    status_command bumblebee-status \\
        -m \\
            date \\
            time \\
        -p \\
            date.format="%d.%m.%y %a [%b]" \\
            date.interval=1m \\
            \\
            time.format="%X" \\
            time.interval=1s
}

#######################################################################
# automatically start i3-config-wizard to offer the user to create a
# keysym-based config which used their favorite modifier (alt or windows)
#
# i3-config-wizard will not launch if there already is a config file
# in ~/.config/i3/config (or \$XDG_CONFIG_HOME/i3/config if set) or
# ~/.i3/config
#
# Please remove the following exec line:
#######################################################################
exec i3-config-wizard

# End ${CONFIG}
EOF

if [ -f "${CONFIG}" ]; then
    mv "${CONFIG}" "${CONFIG}.old"
fi

CONFIG_KEYCODES="/etc/i3/config.keycodes"
if [ -f "${CONFIG_KEYCODES}" ]; then
    mv "${CONFIG_KEYCODES}" "${CONFIG_KEYCODES}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${CONFIG}"
config_file_processing "${CONFIG_KEYCODES}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (an improved dynamic tiling window manager)
#
# i3 is a tiling window manager, completely written from scratch.
#
# i3 was created because wmii, our favorite window manager at the time, didn't
# provide some features we wanted (multi-monitor done right, for example), had
# some bugs, didn't progress since quite some time and wasn't easy to hack at
# all (source code comments/documentation completely lacking). Still, we think
# the wmii developers and contributors did a great job.
#
# Home page: https://www.${PRGNAME}wm.org
# Download:  https://${PRGNAME}wm.org/downloads/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
