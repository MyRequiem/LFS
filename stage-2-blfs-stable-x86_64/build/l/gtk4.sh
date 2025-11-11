#! /bin/bash

PRGNAME="gtk4"
ARCH_NAME="gtk"

### GTK-4 (multi-platform GUI toolkit v4)
# Библиотеки, используемые для создания графических пользовательских
# интерфейсов приложений, предлагающие полный набор виджетов

# Required:    gdk-pixbuf
#              graphene
#              iso-codes
#              libepoxy
#              libxkbcommon
#              pango
#              python3-pygobject3
#              wayland-protocols
# Recommended: adwaita-icon-theme    (по умолчанию для некоторых ключей настроек gtk4)
#              gst-plugins-bad       (собранный с libvpx)
#              glslc
#              gst-plugins-good      (собранный с libvpx)
#              hicolor-icon-theme    (для тестов и для настроек по умолчанию)
#              librsvg
#              vulkan-loader
#              glib
# Optional:    avahi                 (для некоторых тестов)
#              colord
#              cups
#              python3-docutils      (для сборки man-страниц)
#              python3-gi-docgen     (для сборки документации)
#              highlight             (используется gtk4-demo для подсветки синтаксиса исходного кода)
#              libcloudproviders
#              sassc
#              tinysparql
#              accesskit-c           (https://github.com/AccessKit/accesskit-c)
#              cpdb                  (https://github.com/OpenPrinting/cpdb-libs)
#              python3-pydbus        (https://pypi.org/project/pydbus/)
#              sysprof               (https://wiki.gnome.org/Apps/Sysprof)

### Конфигурация:
#    /usr/share/gtk-4.0/settings.ini
#    ~/.config/gtk-4.0/settings.ini

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-4*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
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

# исправим проблему сборки с gcc-15
sed -e '939 s/= { 0, }//'                                       \
    -e '940 a memset (&transform, 0, sizeof(GtkCssTransform));' \
    -i gtk/gtkcsstransformvalue.c || exit 1

mkdir build
cd build || exit 1

meson setup                  \
    --prefix=/usr            \
    --buildtype=release      \
    -D broadway-backend=true \
    -D introspection=enabled \
    -D vulkan=enabled        \
    -D build-examples=false  \
    -D build-tests=false     \
    .. || exit 1

ninja || exit 1

###
# тесты проводятся в графической среде
# если запущена сессия wayland, то вместо x11 указываем wayland
#    --setup wayland
###
# env -u{GALLIUM_DRIVER,MESA_LOADER_DRIVER_OVERRIDE}          \
#     LIBGL_ALWAYS_SOFTWARE=1 VK_LOADER_DRIVERS_SELECT='lvp*' \
#     dbus-run-session meson test --setup x11                 \
#                                 --no-suite={headless,needs-udmabuf}

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (multi-platform GUI toolkit v4)
#
# This is GTK, a multi-platform toolkit for creating graphical user interfaces.
# Offering a complete set of widgets, GTK+ is suitable for projects ranging
# from small one-off projects to complete application suites.
#
# Home page: https://www.${ARCH_NAME}.org/
# Download:  https://download.gnome.org/sources/${ARCH_NAME}/${MAJ_VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
