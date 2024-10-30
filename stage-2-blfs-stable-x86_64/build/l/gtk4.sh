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
#              gst-plugins-bad
#              gst-plugins-good      (собранный с libvpx)
#              hicolor-icon-theme    (для тестов и для настроек по умолчанию)
#              librsvg
#              gobject-introspection
# Optional:    colord
#              cups
#              python3-docutils      (для сборки man-страниц)
#              ffmpeg                (собранный с libvpx)
#              python3-gi-docgen     (для сборки документации)
#              highlight             (используется gtk4-demo для подсветки синтаксиса исходного кода)
#              libcloudproviders
#              sassc
#              tracker
#              vulkan                (https://vulkan.lunarg.com/sdk/home)

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

MAN="false"
EXAMPLES="false"
GTK_DOC="false"
TESTS="false"

command -v docutils &>/dev/null && MAN="true"

mkdir build
cd build || exit 1

meson setup                      \
    --prefix=/usr                \
    --buildtype=release          \
    --sysconfdir=/etc            \
    -Dbroadway-backend=true      \
    -Dwayland-backend=true       \
    -Dman-pages="${MAN}"         \
    -Dbuild-examples=${EXAMPLES} \
    -Dgtk_doc="${GTK_DOC}"       \
    -Dbuild-tests="${TESTS}"     \
    -Dinstall-tests="${TESTS}"   \
    .. || exit 1

ninja ||exit 1

# тесты проводятся в графической среде
# sed "s@'doc'@& / 'gtk-4.8.3'@" -i ../docs/reference/meson.build || exit 1
# meson configure -Dgtk_doc=true ||exit 1
# ninja || exit 1
# meson test --setup x11

DESTDIR="${TMP_DIR}" ninja install

# Конфигурация:
#    /usr/share/gtk-4.0/settings.ini (общесистемная)
#    ~/.config/gtk-4.0/settings.ini
cat << EOF > "${TMP_DIR}/usr/share/gtk-4.0/settings.ini"
[Settings]
gtk-theme-name = Adwaita
gtk-icon-theme-name = oxygen
gtk-font-name = DejaVu Sans 12
gtk-cursor-theme-size = 18
gtk-xft-antialias = 1
gtk-xft-hinting = 1
gtk-xft-hintstyle = hintslight
gtk-xft-rgba = rgb
gtk-cursor-theme-name = Adwaita
EOF

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# Если устанавливается в DESTDIR, то после установки выдает предупреждения:
#    Skipping custom install script because DESTDIR is set '/usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas'
#    Skipping custom install script because DESTDIR is set '/usr/bin/gio-querymodules /usr/lib/gtk-4.0/4.0.0/printbackends'
#    Skipping custom install script because DESTDIR is set '/usr/bin/gio-querymodules /usr/lib/gtk-4.0/4.0.0/media'
#    Skipping custom install script because DESTDIR is set '/tmp/build-gtk4-${VERSION}/gtk-${VERSION}/build/tools/gtk4-update-icon-cache -q -t -f /usr/share/icons/hicolor'
# поэтому запустим вручную:
glib-compile-schemas         /usr/share/glib-2.0/schemas/ &>/dev/null
gio-querymodules             /usr/lib/gtk-4.0/4.0.0/printbackends/
gio-querymodules             /usr/lib/gtk-4.0/4.0.0/media/
gtk4-update-icon-cache -t -f /usr/share/icons/hicolor/

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
