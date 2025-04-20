#! /bin/bash

PRGNAME="xinit"

### xinit (scripts to start X11 server)
# Скрипты для запуска X-сервера

# Required:    xorg-libraries
# Recommended: --- runtime (используются по умолчанию в файле xinitrc) ---
#              twm
#              xclock
#              xterm
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
XINITRC_D="/etc/X11/app-defaults/xinitrc.d"
mkdir -pv "${TMP_DIR}${XINITRC_D}"

# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} \
    --with-xinitdir=/etc/X11/app-defaults || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

XINITRC="/etc/X11/app-defaults/xinitrc"
cat << EOF > "${TMP_DIR}${XINITRC}"
#!/bin/sh

userresources=\$HOME/.Xresources
usermodmap=\$HOME/.Xmodmap
sysresources=/etc/X11/app-defaults/.Xresources
sysmodmap=/etc/X11/app-defaults/.Xmodmap

# merge in defaults and keymaps
[ -f \$sysresources ]  && /usr/bin/xrdb -merge \$sysresources
[ -f \$sysmodmap ]     && /usr/bin/xmodmap     \$sysmodmap
[ -f \$userresources ] && /usr/bin/xrdb -merge \$userresources
[ -f \$usermodmap ]    && /usr/bin/xmodmap     \$usermodmap

if [ -d ${XINITRC_D} ] ; then
    for f in ${XINITRC_D}/?*.sh ; do
        [ -x "\$f" ] && . "\$f"
    done

    unset f
fi

# start i3
if [ -x /usr/bin/dbus-launch ]; then
    exec dbus-launch /usr/bin/i3
else
    exec /usr/bin/i3
fi
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

ldconfig

# если Xorg запускается из командной строки, то он по умолчанию запускается на
# текущем виртуальном терминале. Может быть удобно просмотреть сообщения Xorg
# на текущем виртуальном терминале (обычно tty1) и запустить графическую среду
# на первом доступном неиспользуемом виртуальном терминале, обычно tty7. Для
# этого установим suid-бит для Xorg
chmod u+s "${XORG_PREFIX}/bin/Xorg"
# на этом этапе мы можем запустить Xorg на виртуальном терминале tty7 с помощью
# команды:
#    $ startx [clieng_arguments] -- vt7
# теперь можно переключаться между tty1 и tty7 по Ctrl-Alt-F1 и Ctrl-Alt-F7

# чтобы автоматически запускать Xorg на первом доступном неиспользуемом
# виртуальном терминале, изменим сценарий startx
#
# if [ "$have_vtarg" = "no" ]; then      if [ "$have_vtarg" = "no" ]; then
#     serverargs="$serverargs $vtarg" ->     : #serverargs="$serverargs $vtarg"
# fi                                     fi

sed -i                                        \
    '/$serverargs $vtarg/ s/serverargs/: #&/' \
    "${XORG_PREFIX}/bin/startx" || exit 1

# Например, если в /etc/inittab указано:
#    1:2345:respawn:/sbin/agetty --noclear tty1 9600
#    2:2345:respawn:/sbin/agetty tty2 9600
#    3:2345:respawn:/sbin/agetty tty3 9600
#    4:2345:respawn:/sbin/agetty tty4 9600
#    5:2345:respawn:/sbin/agetty tty5 9600
#    6:2345:respawn:/sbin/agetty tty6 9600
#
# то Xorg будет запускаться на tty7 без указания параметров в командной строке,
# просто запустив
#    $ startx

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (scripts to start X11 server)
#
# xinit is not intended for naive users. Instead, site administrators should
# design user-friendly scripts that present the desired interface when starting
# up X. The startx script is one such example.
#
# Home page: https://www.x.org/pub/individual/app/
# Download:  https://www.x.org/pub/individual/app/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
