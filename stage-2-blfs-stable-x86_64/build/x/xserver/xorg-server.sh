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

# Универсальный драйвер 2D-ускорения для X-сервера, который выполняет
# графические операции через OpenGL. В большинстве современных конфигурациях он
# крайне полезен или даже необходим, особенно для универсального драйвера
# modesetting.
#    -D glamor=true
# Xvfb (X Virtual Framebuffer) - виртуальный X-сервер, который выполняет все
# графические операции в оперативной памяти, не выводя ничего на реальный
# монитор. Крайне полезен в специфических сценариях, например окрытие браузера,
# создание скриншота без участия пользователя, запуск старых игр/программ.
#    -D xvfb=true
# Интеграция с elogind (logind без systemd)
#    -D systemd_logind=true
# Xephyr - вложенный X-сервер, который запускается как обычное окно внутри
# текущей графической сессии. Создает изолированную графическую среду, где
# можно запускать другие оконные менеджеры или приложения, например для их
# тестов.
#    -D xephyr=false
# Xnest - предшественник Xephyr
#    -D xnest=false
# Для очень старых видеокарт (антиквариат)
#    -D dri1=false
# Только для Windows и MacOS
#    -D xwin=false
#    -D xquartz=false
FONT_PATH="/usr/share/fonts/X11/misc,/usr/share/fonts/X11/75dpi,/usr/share/fonts/X11/100dpi,/usr/share/fonts/X11/OTF,/usr/share/fonts/X11/Speedo,/usr/share/fonts/X11/TTF,/usr/share/fonts/X11/Type1,/usr/share/fonts/X11/cyrillic,/usr/share/fonts/util"
meson setup ..                     \
    --prefix="${XORG_PREFIX}"      \
    --localstatedir=/var           \
    -D glamor=true                 \
    -D xvfb=true                   \
    -D systemd_logind=true         \
    -D xephyr=false                \
    -D xnest=false                 \
    -D dri1=false                  \
    -D xwin=false                  \
    -D xquartz=false               \
    -D xkb_output_dir=/var/lib/xkb \
    -D default_font_path="${FONT_PATH}" || exit 1

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
