#! /bin/bash

PRGNAME="conky"

### conky (light-weight system monitor for X)
# Легкий системный монитор для X, который отображает любую информация о системе
# на рабочем столе

# Required:    cmake
#              cairo
#              imlib2
#              lua
#              xorg-libraries
#              libxml2
#              curl
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p build
cd build || exit 1

cmake                                            \
    -D CMAKE_INSTALL_PREFIX=/usr                 \
    -D CMAKE_BUILD_TYPE=Release                  \
    -D BUILD_APCUPSD=OFF                         \
    -D BUILD_CMUS=OFF                            \
    -D BUILD_CURL=ON                             \
    -D BUILD_EXTRAS=ON                           \
    -D BUILD_IPV6=OFF                            \
    -D BUILD_LUA_CAIRO=ON                        \
    -D BUILD_LUA_CAIRO_XLIB=true                 \
    -D BUILD_LUA_IMLIB2=ON                       \
    -D BUILD_LUA_RSVG=ON                         \
    -D BUILD_MOC=OFF                             \
    -D BUILD_MPD=OFF                             \
    -D BUILD_OPENSOUNDSYS=OFF                    \
    -D BUILD_PULSEAUDIO=ON                       \
    -D BUILD_WAYLAND=ON                          \
    -D CURSES_INCLUDE_PATH=/usr/include          \
    -D CURSES_LIBRARY=/usr/lib/libcurses.so      \
    -D LOCALE_DIR=/usr/share/locale              \
    -D PACKAGE_LIBRARY_DIR="/usr/lib/${PRGNAME}" \
    -D USE_CCACHE=OFF                            \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

cd .. || exit 1

rm -rf "${TMP_DIR}"/{vim,nano,usr/share/doc}

# удалим статическую библиотеку
find "${TMP_DIR}" -type f -name "*.a" -exec rm -f {} \;

# man страница
MAN="/usr/share/man/man1"
mkdir -p "${TMP_DIR}${MAN}"
cp "${SOURCES}/${PRGNAME}.1.gz" "${TMP_DIR}${MAN}/"
gunzip "${TMP_DIR}${MAN}/${PRGNAME}.1.gz"

# конфиги по умолчанию
ETC_CONF="/etc/${PRGNAME}"
mkdir -p "${TMP_DIR}${ETC_CONF}"
cp "data/${PRGNAME}.conf"        "${TMP_DIR}${ETC_CONF}/"
cp "data/${PRGNAME}_no_x11.conf" "${TMP_DIR}${ETC_CONF}/"

# файлы подстветки синтаксиса в редакторе Vim для конфигов conkyrc
VIMFILES="/usr/share/vim/vimfiles"
mkdir -p "${TMP_DIR}${VIMFILES}"/{syntax,ftdetect}
cp build/extras/vim/syntax/conkyrc.vim "${TMP_DIR}${VIMFILES}/syntax/"
cp extras/vim/ftdetect/conkyrc.vim     "${TMP_DIR}${VIMFILES}/ftdetect/"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (light-weight system monitor for X)
#
# Conky is a free, light-weight system monitor for X, that displays any kind of
# information on your desktop. It can also run on Wayland (with caveats),
# macOS, output to your console, a file, or even HTTP (oh my!)
#
# Home page: https://${PRGNAME}.cc/
# Download:  https://github.com/brndnmtthws/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
