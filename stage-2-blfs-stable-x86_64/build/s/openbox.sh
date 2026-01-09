#! /bin/bash

PRGNAME="openbox"

### openbox (highly configurable desktop window manager)
# Настраиваемый оконный менеджер рабочего стола с обширной поддержкой
# стандартов. Это позволяет контролировать практически каждый аспект того, как
# мы взаимодействуем со своим рабочим столом.

# Required:    Graphical Environments
#              pango                    (скомпилирован с libxft, т.е. после xorg-libraries)
# Recommended: no
# Optional:    dbus                     (runtime)
#              imlib2                   (для поддержки иконок в меню по ПКМ)
#              imagemagick              (для отображения фона рабочего стола при запуске, см. Конфигурация ниже)
#              python3-pyxdg
#              startup-notification
#              librsvg
#              lxqt-panel               (runtime)

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
# чтобы установить значок в меню по ПКМ
#    ~/.config/openbox/menu.xml
#    добавим значок в тег <item>:
#       <item label="Mplayer" icon="/usr/share/pixmaps/mplayer.png">
#
# многие другие аспекты поведения openbox настраиваются с помощью
#    ~/.config/openbox/rc.xml
# например, какие сочетания клавиш используются для запуска программ или какая
# кнопка мыши запускает главное меню.
#
# тема и ее детали, которую Openbox применяет к окнам, настраивается в
#    ~/.config/openbox/rc.xml
# получить список доступных тем можно командой:
#    $ ls -d /usr/share/themes/*/openbox-3 | sed 's#.*es/##;s#/o.*##'

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# включим поддержку Python3
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-${VERSION}-py3-1.patch" || exit 1

autoreconf -fi        &&
./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

# этот пакет создает три файла .desktop в /usr/share/xsessions/
# Два из них не подходят для BLFS, поэтому удалим их
rm -v "${TMP_DIR}/usr/share/xsessions/openbox"-{gnome,kde}.desktop

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (highly configurable desktop window manager)
#
# Openbox is a highly configurable desktop window manager with extensive
# standards support. It allows you to control almost every aspect of how you
# interact with your desktop
#
# Home page: http://${PRGNAME}.org/
# Download:  http://${PRGNAME}.org/dist/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
