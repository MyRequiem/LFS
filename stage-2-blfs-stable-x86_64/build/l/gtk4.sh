#! /bin/bash

PRGNAME="gtk4"
ARCH_NAME="gtk"

### GTK-4 (multi-platform GUI toolkit v4)
# Библиотеки, используемые для создания графических пользовательских
# интерфейсов приложений, предлагающие полный набор виджетов

# Required:    fribidi
#              gdk-pixbuf
#              graphene
#              iso-codes
#              libepoxy
#              libxkbcommon
#              pango
#              python3-pygobject3
#              wayland-protocols
# Recommended: adwaita-icon-theme    (по умолчанию для некоторых ключей настроек gtk4)
#              gst-plugins-bad       (собранный с libvpx)
#              gst-plugins-good      (собранный с libvpx)
#              hicolor-icon-theme    (для тестов и для настроек по умолчанию)
#              librsvg
#              glib
# Optional:    colord
#              cups
#              python3-docutils      (для сборки man-страниц)
#              python3-gi-docgen     (для сборки документации)
#              highlight             (используется gtk4-demo для подсветки синтаксиса исходного кода)
#              libcloudproviders
#              sassc
#              tracker
#              vulkan-loader
#              cpdb                  (https://github.com/OpenPrinting/cpdb-libs)
#              glslc                 (https://github.com/google/shaderc)
#              sysprof               (https://wiki.gnome.org/Apps/Sysprof)

### Конфигурация:
#    /usr/share/gtk-4.0/settings.ini
#    ~/.config/gtk-4.0/settings.ini

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                  \
    --prefix=/usr            \
    --buildtype=release      \
    -D broadway-backend=true \
    -D introspection=enabled \
    -D vulkan=disabled       \
    -D wayland-backend=false \
    -D build-examples=false  \
    -D build-tests=false     \
    .. || exit 1

ninja || exit 1

# тесты проводятся в графической среде
# dbus-run-session meson test --setup x11

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
