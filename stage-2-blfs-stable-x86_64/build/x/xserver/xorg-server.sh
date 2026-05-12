#! /bin/bash

PRGNAME="xorg-server"

### Xorg-Server (The Xorg server, the core of the X Window System)
# Главный координатор всей графической жизни в системе X11 (X-сервер). Он
# рисует окна, следит за движениями мыши и передает нажатия клавиш нужным
# программам, являясь основой рабочего стола, изначально разработанный для UNIX
# и UNIX-подобных операционных систем.

# Required:    libxcvt
#              pixman
#              xorg-fonts               (только пакет font-util)
#              xkeyboard-config         (runtime и для тестов)
# Recommended: dbus
#              elogind                  (runtime)
#              libepoxy                 (для glamor и xwayland)
#              libtirpc
#              xorg-libinput-driver     (runtime)
# Optional:    acpid                    (runtime)
#              doxygen                  (для документации)
#              fop                      (для документации)
#              libunwind
#              nettle
#              libgcrypt
#              xcb-util-image           (для сборки Xephyr)
#              xcb-util-keysyms         (для сборки Xephyr)
#              xcb-util-renderutil      (для сборки Xephyr)
#              xcb-util-wm              (для сборки Xephyr)
#              xcb-util-cursor          (для сборки Xephyr)
#              xmlto                    (для документации)
#              rendercheck              (для тестов)          https://gitlab.freedesktop.org/xorg/test/rendercheck
#              xorg-sgml-doctools       (для документации)    https://www.x.org/archive/individual/doc/

###
# WARNING:
#    Если мы пересобираем/обновляем пакет, то делать это нужно в чистой TTY
#    (без запущенного Xorg), иначе после пересборки и установки Xorg повиснет
#    (темный экран).
###

###
# Конфигурация ядра
###
# Традиционные драйверы Device Dependent X (DDX), такие как xf86-video-nouveau,
# xf86-video-intel и т.д. были удалены из BLFS в пользу драйвера modesetting
# (modesetting_drv.so), который будет создан как часть этого пакета. Чтобы
# использовать этот драйвер, ядро должно предоставить драйвер Direct Rendering
# Manager (DRM) для графического процессора:
#
#    CONFIG_DRM=y|m
#    CONFIG_DRM_VKMS=y
#    CONFIG_DRM_KMS_HELPER=y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/X11/xorg.conf.d"

# TearFree - опция конфигурации X-сервера, предназначенная для полного
# устранения тиринга (эффекта «разрыва» изображения), возникающего при
# перемещении окон или просмотре видео. В связи с отказом от драйверов
# xf86-video-* (перевода в разряд legacy), опция TearFree перестала работать.
# Чтобы исправить это, разработчики основной ветки (upstream) добавили
# поддержку TearFree в стандартный драйвер modesetting, но не во всех версиях.
# Данный патч переносит этот функционал в текущую версию. Если используем Xorg
# в окружении без композитного менеджера (i3wm, twm, IceWM, Openbox, Fluxbox и
# т.д.) и возникает тиринг, можно попробовать включить TearFree в
# /etc/X11/xorg.conf.d/xorg.conf
#
# Section "Device"
#    Identifier  "VideoCard0"
#    Driver      "modesetting"
#    Option      "PageFlip"    "true"
#    Option      "TearFree"    "true"
#    ...
# EndSection
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
# DGA extension (Direct Graphics Access) считается небезопасным и мертвым уже
# лет 15. Это технология из 90-х, которая позволяла программам (в основном
# играм и ранним плеерам типа MPlayer) писать данные напрямую в видеопамять,
# минуя X-сервер. Это чудовищная дыра в безопасности (программа получает полный
# контроль над видеокартой). С появлением DRI (Direct Rendering Infrastructure)
# и KMS в ядре, DGA стал не просто не нужен, а вреден. Он часто вызывает
# падения сервера при попытке переключить разрешение. Значение по умолчанию
# 'auto', но meson увидев пакеты типа xorgproto может включит опцию в 'true' и
# соберет его.
#    -D dga=false
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
    -D dga=false                   \
    -D xkb_output_dir=/var/lib/xkb \
    -D default_font_path="${FONT_PATH}" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# Установка SUID-бита на /usr/bin/Xorg позволяет серверу получать прямой доступ
# к оборудованию при запуске от обычного пользователя без рутинной настройки
# прав через eudev/elogind. Это классический, проверенный временем метод,
# гарантирующий запуск графики в любых условиях.
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
