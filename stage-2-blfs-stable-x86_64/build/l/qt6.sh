#! /bin/bash

PRGNAME="qt6"
ARCH_NAME="qt-everywhere-src"

### Qt (a multi-platform C++ graphical user interface toolkit)
# Самая современная версия графического фреймворка, на котором строятся
# интерфейсы будущего. Она предлагает улучшенную скорость работы, поддержку
# новейших видеокарт и современные инструменты для создания красивых программ.
# Одним из основных пользователей Qt является KDE Frameworks 6 (KF6).

# Required:    xorg-libraries
# Recommended: alsa-lib
#              make-ca
#              libcups или cups
#              dbus
#              double-conversion
#              glib
#              ffmpeg                       (для qtmultimedia backend)
#              gst-plugins-base             (для qtmultimedia backend)
#              gst-plugins-good             (для qtmultimedia backend)
#              harfbuzz
#              icu
#              jasper
#              libjpeg-turbo
#              libinput
#              libmng
#              libpng
#              libtiff
#              libwebp
#              libxkbcommon
#              mesa
#              mtdev
#              xcb-util-cursor
#              xcb-util-image
#              xcb-util-keysyms
#              xcb-util-renderutil
#              xcb-util-wm
# Optional:    gtk+3
#              llvm
#              mit-kerberos-v5
#              pciutils
#              protobuf
#              pulseaudio
#              sdl2-compat
#              unixodbc

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

# Для сборки версии 6.12.0 требуется ~60Gb дискового пространства. поэтому
# собираем НЕ в разделе /tmp (30Gb), а в разделе где хватает места.
BUILD_DIR="/home/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \+ -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \+

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"

# Устанавливаем в /opt
export QT6PREFIX="/opt/${PRGNAME}-${VERSION}"

mkdir -pv "${TMP_DIR}/etc"/{profile.d,sudoers.d,ld.so.conf.d}
mkdir -pv "${TMP_DIR}${QT6PREFIX}"

# ==============================================================================
###
# КОНФИГУРАЦИЯ:
###
# Не собирать тяжелые примеры кода и демо-приложения.
#    -nomake examples
# Не собирать тесты.
#    -nomake tests
# Не зашивать жесткие пути к библиотекам (RPATH) в бинарники.
#    -no-rpath
# Отключить генерацию отчетов Software Bill of Materials.
#    -no-sbom
# Отправлять системные логи Qt в стандартный демон syslog.
#    -syslog
# Отвязать Qt6 от логирования в systemd (systemd-journald). У нас чистый
# SysVinit.
#    -no-journald
# Отключить поддержку древних резистивных тачскринов (привет из 2000-х). Полный
# рудимент для ПК.
#    -no-tslib
# Отключить древний графический бэкенд (фреймворк DirectFB) для вывода на экран
# в обход X11/Wayland.
#    -no-directfb
# Отключить поддержку печати на принтерах через CUPS.
#    -no-cups
# Полностью отключить поддержку Wayland и его плагинов.
#    -D FEATURE_wayland=OFF
# Графический редактор форм UI (Designer).
#    -D FEATURE_designer=OFF
# Программа просмотра документации (Assistant).
#    -D FEATURE_assistant=OFF
# Утилита для перевода и локализации (Linguist).
#    -D FEATURE_linguist=OFF
# Экранная лупа для точного замера пикселей.
#    -D FEATURE_pixeltool=OFF
# Генератор 3D-шрифтов (SDF) для встроенных систем.
#    -D FEATURE_distancefieldgenerator=OFF
# ==============================================================================
# Вырезаем тяжелый модуль 3D-графики.
rm -rf qt3d
# Вырезаем физический движок для Quick3D.
rm -rf qtquick3dphysics
# Вырезаем монструозный Chromium-движок браузера (в версии qt-6.12.0 его уже
# нет, вынесен в отдельный проект, но оставим на всякий случай).
rm -rf qtwebengine
# Промышленная автоматизация (для связи с промышленным оборудованием). Не
# требуется для стандартных GUI/десктопных приложений.
rm -rf qtopcua
# Вырезаем медиа-движок (не нужен для VLC, mpv, LXQt и т.д.).
rm -rf qtmultimedia
# Синтез речи Text-to-Speech (озвучка текста голосом через Speech Dispatcher).
rm -rf qtspeech
# Вырезаем поддержку Bluetooth и NFC. Qt-приложения для LXQt его не просят.
rm -rf qtconnectivity
# Вырезаем позиционирование и гео-карты (нужно для всяких фитнес-трекеров или
# навигаторов). В ПК-дистрибутиве мертвый груз.
rm -rf qtlocation
# Вырезаем поддержку датчиков (акселерометр, датчик света, гироскоп). Нужно
# только для планшетов и мобилок.
rm -rf qtsensors
# Вырезаем специфические фреймворки создания диаграмм состояний (SCXML) для
# программистов. Обычному софту и DE не нужны вообще.
rm -rf qtscxml
rm -rf qtstatemachine
# ==============================================================================
./configure                  \
    -prefix "${QT6PREFIX}"   \
    -sysconfdir /etc/xdg     \
    -dbus-linked             \
    -openssl-linked          \
    -system-sqlite           \
    -nomake examples         \
    -nomake tests            \
    -no-rpath                \
    -no-sbom                 \
    -syslog                  \
    -no-journald             \
    -no-tslib                \
    -no-directfb             \
    -no-cups                 \
    -D FEATURE_wayland=OFF   \
    -D FEATURE_designer=OFF  \
    -D FEATURE_assistant=OFF \
    -D FEATURE_linguist=OFF  \
    -D FEATURE_pixeltool=OFF \
    -D FEATURE_distancefieldgenerator=OFF || exit 1

ninja || exit 1
# Пакет не имеет набора тестов.
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# Удалим ссылки на каталог сборки из установленных библиотек:
#    /opt/${PRGNAME}/lib/libQt6Purchasing.prl
#    /opt/${PRGNAME}/lib/libQt6MultimediaQuick.prl
#    ...
#    ...
find "${TMP_DIR}${QT6PREFIX}"/ -name \*.prl \
    -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \+

# QT6DIR также должен быть доступен пользователю root.
SUDOERS="/etc/sudoers.d/${PRGNAME}"
cat > "${TMP_DIR}${SUDOERS}" << "EOF"
Defaults env_keep += QT6DIR
EOF
chmod 440 "${TMP_DIR}${SUDOERS}"

# Добавим путь поиска библиотек для динамического загрузчика.
cat << EOF > "${TMP_DIR}/etc/ld.so.conf.d/${PRGNAME}.conf"
${QT6PREFIX}/lib
EOF

QT6_SH="/etc/profile.d/${PRGNAME}.sh"
cat << EOF > "${TMP_DIR}${QT6_SH}"
# Begin ${QT6_SH}

QT6DIR=${QT6PREFIX}

PATH="\${PATH}:\${QT6DIR}/bin"
PKG_CONFIG_PATH="\${PKG_CONFIG_PATH}:\${QT6DIR}/lib/pkgconfig"
QT_PLUGIN_PATH=\${QT6DIR}/plugins
QML2_IMPORT_PATH=\${QT6DIR}/qml

export QT6DIR PATH PKG_CONFIG_PATH QT_PLUGIN_PATH QML2_IMPORT_PATH

# End ${QT6_SH}
EOF
chmod 755 "${TMP_DIR}${QT6_SH}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# Обновим кэш динамического загрузчика.
ldconfig

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a multi-platform C++ graphical user interface toolkit)
#
# Qt6 is a cross-platform C++ application framework that is widely used for
# developing application software with a graphical user interface (GUI) (in
# which cases Qt6 is classified as a widget toolkit), and also used for
# developing non-GUI programs such as command-line tools and consoles for
# servers. One of the major users of Qt is KDE Frameworks 6 (KF6).
#
# Home page: https://qt-project.org/
# Download:  https://mirror-hk.koddos.net/blfs/conglomeration/${PRGNAME}/qt-everywhere-src-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
