#! /bin/bash

PRGNAME="xscreensaver"

### XScreenSaver (a screen saver and locker for X)
# Скринсейвер и блокировщик для X11, который автоматически запускает
# анимированные заставки после периода бездействия пользователя, а также
# отвечает за блокировку экрана для защиты от несанкционированного доступа.

# Required:    gtk+3
#              xorg-applications
# Recommended: glu
# Optional:    gdm
#              ffmpeg
#              linux-pam
#              mit-kerberos-v5
#              gle                  (https://linas.org/gle/)

### Конфиги
#    /etc/X11/app-defaults/XScreenSaver
#    ~/.xscreensaver

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/pam.d"

./configure       \
    --prefix=/usr \
    --with-elogind || exit 1

make || exit 1
# пакет не имеет набора тестов
make install_prefix="${TMP_DIR}" install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# Linux PAM конфигурация
cat << EOF > "${TMP_DIR}/etc/pam.d/xscreensaver"
auth    include system-auth
account include system-account
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a screen saver and locker for X)
#
# The XScreenSaver package is a modular screen saver and locker for the X
# Window System. It is highly customizable and allows the use of any program
# that can draw on the root window as a display mode. The purpose of
# XScreenSaver is to display pretty pictures on your screen when it is not in
# use, in keeping with the philosophy that unattended monitors should always be
# doing something interesting, just like they do in the movies. However,
# XScreenSaver can also be used as a screen locker, to prevent others from
# using your terminal while you are away.
#
# Home page: https://www.jwz.org/${PRGNAME}/
# Download:  https://www.jwz.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
