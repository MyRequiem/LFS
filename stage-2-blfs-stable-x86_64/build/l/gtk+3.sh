#! /bin/bash

PRGNAME="gtk+3"
ARCH_NAME="gtk+"

### GTK+3 (multi-platform GUI toolkit)
# GTK (GIMP ToolKit) - кроссплатформенная библиотека элементов интерфейса
# (фреймворк). Наряду с библиотекой Qt является одной из наиболее популярных на
# сегодняшний день библиотек для X Window System.

# Required:    at-spi2-atk
#              gdk-pixbuf
#              libepoxy
#              pango
# Recommended: adwaita-icon-theme (для некоторых настроек gtk+3 и для тестов)
#              hicolor-icon-theme (для тестов)
#              iso-codes
#              libxkbcommon
#              sassc
#              wayland
#              wayland-protocols
#              gobject-introspection
# Optional:    colord
#              cups
#              docbook-utils
#              gtk-doc
#              json-glib
#              pyatspi2 (для тестов)
#              rest
#              papi     (http://icl.cs.utk.edu/papi/)

###
# Конфигурация
###
#    ~/.config/gtk-3.0/settings.ini
#    /etc/gtk-3.0/settings.ini

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-3*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

WAYLAND="--disable-wayland-backend"
GTK_DOC="--disable-gtk-doc"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"

# включаем X11 GDK бэкэнд
#    --enable-x11-backend
# включаем GTK Broadway (HTML5) бэкэнд
#    --enable-broadway-backend
./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    "${WAYLAND}"         \
    "${GTK_DOC}"         \
    --enable-x11-backend \
    --enable-broadway-backend || exit 1

make || exit 1

# тесты
# сначала создадим/обновим /usr/share/glib-2.0/schemas/gschemas.compiled
# (если в директории присутствуют файлы схем *.xml)
# glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null
#
# запускать тесты нужно только в графической среде
# make check

make install DESTDIR="${TMP_DIR}"

[[ "x${GTK_DOC}" == "x--disable-gtk-doc" ]] && \
    rm -rf "${TMP_DIR}/usr/share/gtk-doc"

IM_MULTIPRESS_CONF="/etc/gtk-3.0/im-multipress.conf"
if [ -f "${IM_MULTIPRESS_CONF}" ]; then
    mv "${IM_MULTIPRESS_CONF}" "${IM_MULTIPRESS_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${IM_MULTIPRESS_CONF}"

# создадим/обновим /usr/share/glib-2.0/schemas/gschemas.compiled
# (если в директории присутствуют файлы схем *.xml)
glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null

# создадим/обновим кэш модулей GTK+3 /usr/lib/gtk-3.x/3.x.x/immodules.cache
gtk-query-immodules-3.0 --update-cache &>/dev/null

# копируем созданный immodules.cache в ${TMP_DIR}
IMMODULES_CACHE="$(find /usr/lib/gtk-3* -type f -name immodules\.cache)"
cp "${IMMODULES_CACHE}" "${TMP_DIR}${IMMODULES_CACHE}"

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (multi-platform GUI toolkit)
#
# This is GTK+3, a multi-platform toolkit (libraries) for creating graphical
# user interfaces for applications. Offering a complete set of widgets, GTK+ is
# suitable for projects ranging from small one-off projects to complete
# application suites.
#
# Home page: https://www.gtk.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
