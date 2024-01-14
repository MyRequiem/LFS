#! /bin/bash

PRGNAME="gtk+3"
ARCH_NAME="gtk+"

### GTK+3 (multi-platform GUI toolkit)
# GTK (GIMP ToolKit) - кроссплатформенная библиотека элементов интерфейса
# (фреймворк). Наряду с библиотекой Qt является одной из наиболее популярных на
# сегодняшний день библиотек для X

# Required:    at-spi2-core
#              gdk-pixbuf
#              libepoxy
#              pango
# Recommended: adwaita-icon-theme    (для некоторых настроек gtk+3 и для тестов)
#              docbook-xsl           (для создания man-страниц)
#              hicolor-icon-theme    (для тестов)
#              iso-codes
#              libxkbcommon
#              libxslt               (для создания man-страниц)
#              sassc
#              wayland
#              wayland-protocols
#              gobject-introspection
# Optional:    colord
#              cups
#              gtk-doc
#              python3-pyatspi2 (для тестов)
#              tracker
#              papi                  (https://icl.utk.edu/papi/)

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

MAN="false"
GTK_DOC="false"
EXAMPLES="false"
TESTS="false"
INSTALLED_TESTS="false"
WAYLAND_BACKEND="false"
TRACKER="false"

# shellcheck disable=SC2144
[ -d /usr/share/xml/docbook/xsl-stylesheets-* ] && \
    command -v xslt-config &>/dev/null && MAN="true"
# command -v gtkdoc-check &>/dev/null && GTK_DOC="true"
[ -d /usr/share/wayland-protocols ] && WAYLAND_BACKEND="true"
command -v tracker3 &>/dev/null && TRACKER="true"

mkdir build
cd build || exit 1

meson setup                                \
    --prefix=/usr                          \
    --buildtype=release                    \
    -Dman="${MAN}"                         \
    -Dbroadway_backend=true                \
    -Dgtk_doc="${GTK_DOC}"                 \
    -Dexamples="${EXAMPLES}"               \
    -Dtests="${TESTS}"                     \
    -Dinstalled_tests="${INSTALLED_TESTS}" \
    -Dwayland_backend="${WAYLAND_BACKEND}" \
    -Dtracker3="${TRACKER}"                \
    .. || exit 1

ninja || exit 1

# тесты проводятся в графической среде + установить переменную TESTS="true"
# ninja test

DESTDIR="${TMP_DIR}" ninja install

[[ "x${GTK_DOC}" == "xfalse" ]] && \
    rm -rf "${TMP_DIR}/usr/share/gtk-doc"

IM_MULTIPRESS_CONF="/etc/gtk-3.0/im-multipress.conf"
if [ -f "${IM_MULTIPRESS_CONF}" ]; then
    mv "${IM_MULTIPRESS_CONF}" "${IM_MULTIPRESS_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${IM_MULTIPRESS_CONF}"

# создадим/обновим кэш модулей GTK+3 /usr/lib/gtk-3.x/3.x.x/immodules.cache и
# скопируем его в ${TMP_DIR}
gtk-query-immodules-3.0 --update-cache &>/dev/null
IMMODULES_CACHE="$(find /usr/lib/gtk-3* -type f -name immodules\.cache)"
cp "${IMMODULES_CACHE}" "${TMP_DIR}${IMMODULES_CACHE}"

# создадим/обновим /usr/share/glib-2.0/schemas/gschemas.compiled
# (если в директории присутствуют файлы схем *.xml)
glib-compile-schemas /usr/share/glib-2.0/schemas &>/dev/null

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
