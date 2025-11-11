#! /bin/bash

PRGNAME="xinit"

### xinit (scripts to start X11 server)
# Скрипты для запуска X-сервера

# Required:    xorg-libraries
# Recommended: --- runtime ---
#              --- используются по умолчанию в /etc/X11/app-defaults/xinitrc
#              --- при запуске xorg-server, если не существует ~/.xinitrc
#              twm
#              xclock
#              xterm
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/X11/app-defaults/xinitrc.d"

# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} \
    --with-xinitdir=/etc/X11/app-defaults || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

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

# shellcheck disable=SC2016
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
