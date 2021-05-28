#! /bin/bash

PRGNAME="xinit"

### xinit (scripts to start X11 server)
# Скрипты для запуска X-сервера

# Required:    xorg-libraries
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

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

if [ -f "${XINITRC}" ]; then
    mv "${XINITRC}" "${XINITRC}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${XINITRC}"

ldconfig

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (scripts to start X11 server)
#
# xinit is not intended for naive users. Instead, site administrators should
# design user-friendly scripts that present the desired interface when starting
# up X. The startx script is one such example.
#
# Home page: https://www.x.org/pub/individual/app/
# Download:  https://www.x.org/pub/individual/app/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
