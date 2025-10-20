#! /bin/bash

PRGNAME="xorg-server"

### Xorg-Server (The Xorg server, the core of the X Window System)
# Полнофункциональный X-сервер, изначально разработанный для UNIX и
# UNIX-подобных операционных систем.

# Required:    libxcvt
#              pixman
#              xorg-fonts           (только пакет font-util)
#              xkeyboard-config     (runtime и для тестов)
# Recommended: dbus
#              elogind              (runtime)
#              libepoxy             (для glamor и xwayland)
#              libtirpc
#              xorg-libinput-driver (runtime)
# Optional:    acpid                (runtime)
#              doxygen              (для документации)
#              fop                  (для документации)
#              libunwind
#              nettle
#              libgcrypt
#              xcb-util-image       (для сборки Xephyr)
#              xcb-util-keysyms     (для сборки Xephyr)
#              xcb-util-renderutil  (для сборки Xephyr)
#              xcb-util-wm          (для сборки Xephyr)
#              xcb-util-cursor      (для сборки Xephyr)
#              xmlto                (для документации)
#              rendercheck          (для тестов)          https://gitlab.freedesktop.org/xorg/test/rendercheck
#              xorg-sgml-doctools   (для документации)    https://www.x.org/archive/individual/doc/

###
# WARNING:
#    Если мы пересобираем/обновляем пакет, то делать это нужно в ЧИСТОЙ КОНСОЛИ
#    (без запущенного Xorg), иначе после пересборки и установки темный экран и
#    Xorg виснет
###

###
# Конфигурация ядра
###
# традиционные драйверы Device Dependent X (DDX), такие как xf86-video-nouveau,
# xf86-video-intel и т.д.  были удалены из BLFS в пользу драйвера
# modesetting_drv, который будет создан как часть этого пакета. Чтобы
# использовать этот драйвер, ядро должно предоставить драйвер Direct Rendering
# Manager (DRM) для графического процессора
#
# CONFIG_DRM=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/X11/xorg.conf.d"

# после удаления драйверов xf86-video-* опция TearFree больше не работает.
# Чтобы обойти эту проблему добавили параметр TearFree в modesetting (драйвер
# по умолчанию). Применим этот патч, если будем использовать Xorg в среде без
# композитора (i3, TWM, IceWM, Openbox, Fluxbox и т.д.)
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-tearfree_backport-1.patch" || exit 1

mkdir build
cd build || exit 1

meson setup ..                \
    --prefix="${XORG_PREFIX}" \
    --localstatedir=/var      \
    -D glamor=true            \
    -D systemd_logind=true    \
    -D xephyr=true            \
    -D xkb_output_dir=/var/lib/xkb || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

chmod u+s /usr/bin/Xorg

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The Xorg server, the core of the X Window System)
#
# Xorg is a full featured X server that was originally designed for UNIX and
# UNIX-like operating systems running on Intel x86 hardware. It now runs on a
# wider range of hardware and OS platforms. This work was derived by the X.Org
# Foundation from the XFree86 Project's XFree86 4.4rc2 release. The XFree86
# release was originally derived from X386 1.2 by Thomas Roell which was
# contributed to X11R5 by Snitily Graphics Consulting Service.
#
#
# Home page: https://www.x.org
# Download:  https://www.x.org/pub/individual/xserver/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
