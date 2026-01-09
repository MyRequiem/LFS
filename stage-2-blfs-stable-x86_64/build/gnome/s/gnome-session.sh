#! /bin/bash

PRGNAME="gnome-session"

### GNOME Session (GNOME Session Manager)
# Запускает среду рабочего стола GNOME и управляет ею после входа пользователя.
# Обычно вызывается менеджером входа в систему GDM, чтобы инициализировать все
# необходимые компоненты и запустить графический интерфейс.

# Required:    elogind
#              gnome-desktop
#              json-glib
#              mesa
#              upower
# Recommended: no
# Optional:    --- для документации ---
#              xmlto
#              libxslt
#              docbook-xml
#              docbook-xsl

###
# NOTE
###
# Для запуска GNOME командой startx в ~/.xinitrc добавляем
#    dbus-run-session gnome-session
#    или
#    export XDG_SESSION_TYPE=wayland dbus-run-session gnome-session
#
# Сессия на Xorg
#    export XDG_SESSION_TYPE=x11
#    export GDK_BACKEND=x11
#    dbus-run-session gnome-session
#
# GNOME Classic - режим рабочего стола в GNOME, который предоставляет
# традиционный интерфейс, похожий на GNOME 2, с панелями вверху и внизу экрана,
# меню 'Приложения' и списком окон. Создан для пользователей, предпочитающих
# более привычную среду, и на самом деле является специально настроенной
# версией современного GNOME, а не отдельной веткой разработки
#    dbus-run-session gnome-session --session=gnome-classic
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# при запуске GNOME под Wayland системные настройки среды (глобальные
# переменные и т.д.) не импортируются для пользователя использующего системный
# профиль. Разработчики Wayland в настоящее время не определились со
# стандартным методом предоставления этих настроек для пользовательских
# сеансов. Обойдем это ограничение, чтобы сеанс gnome использовал login shell
sed 's@/bin/sh@/bin/sh -l@' -i gnome-session/gnome-session.in || exit 1

mkdir build
cd build || exit 1

meson setup                    \
    --prefix=/usr              \
    --buildtype=release        \
    -D systemduserunitdir=/tmp \
    .. || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

# Файлы .desktop в каталогах
#    /usr/share/xsessions/           (файлы запуска Xorg сессии)
#    /usr/share/wayland-sessions/    (файлы запуска Wayland сессии)
# нужны для менеджеров запуска графических сеансов (sddm, gdm и др.)
#
# NOTE:
#    В каждом каталоге системы BLFS необходим ТОЛЬКО ОДИН файл для каждого
#    графического сеанса

# пакет создает два файла .desktop на основе Xorg
#    /usr/share/xsessions/gnome{,-xorg}.desktop
# и два файла на основе Wayland
#    /usr/share/wayland-sessions/gnome{,-wayland}.desktop
#
# удалим лишние:
rm -f "${TMP_DIR}/usr/share/xsessions/gnome.desktop"
rm -f "${TMP_DIR}/usr/share/wayland-sessions/gnome.desktop"

# удалим модули systemd, которые бесполезны в нашей SysV системе
rm -rf "${TMP_DIR}/tmp"

# последовательность запуска gnome-wayland требует создания сеанса DBus. В
# нашей SysV системе это необходимо добавить в поставляемый файл
# gnome-wayland.desktop, по умолчанию написанный для systemd
sed -e 's@^Exec=@&/usr/bin/dbus-run-session @' \
    -i "${TMP_DIR}/usr/share/wayland-sessions/gnome-wayland.desktop" || exit 1

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GNOME Session Manager)
#
# The GNOME Session package contains the GNOME session manager
#
# Home page: https://github.com/GNOME/${PRGNAME}
# Download:  https://download.gnome.org/sources/${PRGNAME}/${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
