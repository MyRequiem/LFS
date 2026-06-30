#! /bin/bash

PRGNAME="openbox"

### openbox (highly configurable desktop window manager)
# Легковесный, высокоскоростной и крайне минималистичный оконный менеджер для
# графической системы X11. Он не содержит лишних элементов декора и идеально
# подходит для сборки быстрых рабочих окружений.

# Required:    Graphical Environments
#              pango                        (скомпилирован с libxft, т.е. после xorg-libraries)
# Recommended: no
# Optional:    dbus                         (runtime)
#              imlib2                       (для поддержки иконок в меню по ПКМ)
#              imagemagick или feh          (runtime, для отображения фона рабочего стола при запуске)
#              python3-pyxdg
#              startup-notification
#              librsvg

###
# Запуск Openbox командой startx
###
#    ~/.xinitrc
#       # установим обои (требуется пакет feh)
#       command -v feh &>/dev/null && feh --bg-fill "<path_to_wallpaper_image>"
#       eval $(dbus-launch --auto-syntax --exit-with-session)
#       lxqt-panel &
#       exec openbox
###
# Конфигурация
###
#    /etc/xdg/openbox/autostart
#    /etc/xdg/openbox/menu.xml
#    /etc/xdg/openbox/rc.xml
#    ~/.config/openbox/autostart
#    ~/.config/openbox/menu.xml
#    ~/.config/openbox/rc.xml
#
# Правой кнопки мыши вызывается меню Openbox которое можно использовать для
# запуска программ. Само меню настраивается с помощью двух файлов:
#    /etc/xdg/openbox/menu.xml
#    ~/.config/openbox/menu.xml
#
#    $ cp -rf /etc/xdg/openbox ~/.config/
#
# Чтобы установить значок в меню по ПКМ
#    ~/.config/openbox/menu.xml
#    Добавим значок в тег <item>, например, для Gimp:
#       <item label="Gimp" icon="/usr/share/icons/hicolor/16x16/apps/gimp.png">
#
# Многие другие аспекты поведения openbox настраиваются с помощью
#    ~/.config/openbox/rc.xml
# Например, какие сочетания клавиш используются для запуска программ или какая
# кнопка мыши запускает главное меню.
#
# Тема и ее детали, которую Openbox применяет к окнам, настраивается в
#    ~/.config/openbox/rc.xml
# Получить список доступных тем можно командой:
#    $ ls -d /usr/share/themes/*/openbox-3 | sed 's#.*es/##;s#/o.*##'

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Включим поддержку Python3
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-${VERSION}-py3-1.patch" || exit 1

autoreconf -fi || exit 1
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# Пакет не имеет набора тестов.
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# Этот пакет создает три файла .desktop в /usr/share/xsessions/
# Два из них не подходят для BLFS, поэтому удалим их:
rm -v "${TMP_DIR}/usr/share/xsessions/openbox"-{gnome,kde}.desktop

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (highly configurable desktop window manager)
#
# Openbox is a highly configurable desktop window manager with extensive
# standards support. It allows you to control almost every aspect of how you
# interact with your desktop
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/dist/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
