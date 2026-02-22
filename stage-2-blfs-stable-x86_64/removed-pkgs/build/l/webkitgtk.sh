#! /bin/bash

PRGNAME="webkitgtk"

### WebKitGTK (portable web rendering engine WebKit for GTK+3)
# Движок веб-рендеринга WebKit для платформ GTK+3

# Required:    cairo
#              cmake
#              gst-plugins-base
#              gst-plugins-bad
#              gtk+3
#              gtk4
#              icu
#              lcms2
#              libgudev
#              libsecret
#              libsoup3
#              libtasn1
#              libwebp
#              mesa
#              openjpeg
#              ruby
#              sqlite
#              unifdef
#              which
# Recommended: bubblewrap
#              enchant
#              geoclue                  (runtime)
#              glib
#              hicolor-icon-theme
#              libavif
#              libjxl
#              libseccomp
#              xdg-dbus-proxy
# Optional:    python3-gi-docgen
#              harfbuzz
#              wayland
#              woff2
#              ccache                   (https://ccache.dev/)
#              flite                    (http://www.festvox.org/flite/)
#              hyphen                   (https://sourceforge.net/projects/hunspell/files/Hyphen/)
#              libbacktrace             (https://github.com/ianlancetaylor/libbacktrace)
#              libmanette               (https://gnome.pages.gitlab.gnome.org/libmanette/)
#              libspiel                 (https://github.com/project-spiel/libspiel)
#              sysprof                  (https://wiki.gnome.org/Apps/Sysprof)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

###
# Пробовал собирать в 16, 8, 4 и 2 потока.
# Ninja пропатчена:
#    src/ninja.cc
#    функция GuessParallelism теперь возвращает адекватное количество потоков
#    при использовании переменной окружения NINJAJOBS, а не сумашедшие
#    $(($(npoc) + 2))
#
# Примерно на 30% сборки компиляция прерывается с разными ошибками. То он в
# конце сишного исходника видит недопустимую пустую строку в конце файла:), то
# функции передано неверное количество аргументов, то
#    ninja: build stopped: subcommand failed
#
# Оборудование:
#    Ноут ASUS TUF FA808UM-S8030
#    Процессор AMD Ryzen 7 260 (8 x 3.8ГГц, 16 потоков)
#    RAM: 16 Гб
#                                                                  (-^^-)
# Без ошибок пакет собрался только в 1 поток за 37 часов 23 минуты ХаХаХаХа
###                                                                (-^^-)
export NINJAJOBS="-j1"

# GTK+3
mkdir -p build3 build4
cd build3 || exit 1

cmake                               \
    -D CMAKE_BUILD_TYPE=Release     \
    -D CMAKE_INSTALL_PREFIX=/usr    \
    -D CMAKE_SKIP_INSTALL_RPATH=ON  \
    -D PORT=GTK                     \
    -D LIB_INSTALL_DIR=/usr/lib     \
    -D USE_LIBBACKTRACE=OFF         \
    -D USE_LIBHYPHEN=OFF            \
    -D ENABLE_GAMEPAD=OFF           \
    -D ENABLE_MINIBROWSER=ON        \
    -D ENABLE_DOCUMENTATION=OFF     \
    -D ENABLE_WEBDRIVER=OFF         \
    -D USE_WOFF2=ON                 \
    -D USE_GTK4=OFF                 \
    -D ENABLE_JOURNALD_LOG=OFF      \
    -D ENABLE_BUBBLEWRAP_SANDBOX=ON \
    -D USE_SYSPROF_CAPTURE=NO       \
    -D ENABLE_SPEECH_SYNTHESIS=OFF  \
    -W no-dev                       \
    -G Ninja                        \
    .. || exit 1

ninja "${NINJAJOBS}" || exit 1
# пакет не имеет набора тестов, но для проверки можно запустить минибраузер
# в графической среде
#    $ build/bin/MiniBrowser
DESTDIR="${TMP_DIR}" ninja install || exit 1

# GTK4
cd ../build4 || exit 1
cmake                               \
    -D CMAKE_BUILD_TYPE=Release     \
    -D CMAKE_INSTALL_PREFIX=/usr    \
    -D CMAKE_SKIP_INSTALL_RPATH=ON  \
    -D PORT=GTK                     \
    -D LIB_INSTALL_DIR=/usr/lib     \
    -D USE_LIBBACKTRACE=OFF         \
    -D USE_LIBHYPHEN=OFF            \
    -D ENABLE_GAMEPAD=OFF           \
    -D ENABLE_MINIBROWSER=ON        \
    -D ENABLE_DOCUMENTATION=OFF     \
    -D USE_WOFF2=ON                 \
    -D USE_GTK4=ON                  \
    -D ENABLE_JOURNALD_LOG=OFF      \
    -D ENABLE_BUBBLEWRAP_SANDBOX=ON \
    -D USE_SYSPROF_CAPTURE=NO       \
    -D ENABLE_SPEECH_SYNTHESIS=OFF  \
    -W no-dev                       \
    -G Ninja                        \
    .. || exit 1

ninja "${NINJAJOBS}" || exit 1
DESTDIR="${TMP_DIR}" ninja install || exit 1

rm -rf "${TMP_DIR}/usr/share/doc"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (portable web rendering engine WebKit for GTK+3)
#
# The WebKitGTK package is a port of the portable web rendering engine WebKit
# to the GTK+3 platforms
#
# Home page: https://${PRGNAME}.org/
# Download:  https://${PRGNAME}.org/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
