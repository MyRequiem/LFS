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
#              glib
# Optional:    colord
#              cups
#              gtk-doc
#              libcloudproviders
#              python3-pyatspi2      (для тестов)
#              tracker
#              papi                  (https://icl.utk.edu/papi/)

###
# Конфигурация
###
#    ~/.config/gtk-3.0/settings.ini
#    /etc/gtk-3.0/settings.ini

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

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

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..               \
    --prefix=/usr            \
    --buildtype=release      \
    -D broadway_backend=true \
    -D examples=false        \
    -D tests=false           \
    -D wayland_backend=false || exit 1

ninja || exit 1
# тесты нужно запускать в графической среде
# dbus-run-session ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# создадим/обновим кэш модулей GTK+3 /usr/lib/gtk-3.x/3.x.x/immodules.cache
gtk-query-immodules-3.0 --update-cache

# создадим/обновим /usr/share/glib-2.0/schemas/gschemas.compiled
glib-compile-schemas /usr/share/glib-2.0/schemas

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
