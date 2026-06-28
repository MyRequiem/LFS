#! /bin/bash

PRGNAME="flameshot"

### Flameshot (screenshot software)
# Мощная и функциональная графическая программа для создания скриншотов с
# возможностью мгновенного редактирования. Она позволяет рисовать стрелки,
# размывать текст, добавлять надписи и др. прямо перед сохранением.

# Required:    md4c
#              nodejs
#              double-conversion
#              qt6
#              llvm
#              librsvg
#              libxkbcommon
# Recommended: xdg-desktop-portal    - если не установлен, то после сборки
#                                       запускаем flameshot: Settings ->
#                                       General -> "Use legacy X11 screenshot
#                                       method" или в
#                                       ~/.config/flameshot/flameshot.ini
#                                       добавляем параметр:
#                                       useX11LegacyScreenshot=true
# Optional:    git
#              openssh
#              p11-kit

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -p build
cd build || exit 1

cmake                                       \
    -D CMAKE_INSTALL_PREFIX=/usr            \
    -D CMAKE_BUILD_TYPE=Release             \
    -D BUILD_SHARED_LIBS=ON                 \
    -D BUILD_STATIC_LIBS=OFF                \
    -D KDSingleApplication_STATIC=OFF       \
    -D QTCOLORWIDGETS_BUILD_STATIC_LIBS=OFF \
    -W no-dev                               \
    .. || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (screenshot software)
#
# Powerful yet simple to use screenshot software. Features: Customizable
# appearance. In-app screenshot edition. DBus interface.
#
# Home page: https://${PRGNAME}.org
# Download:  https://github.com/${PRGNAME}-org/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
