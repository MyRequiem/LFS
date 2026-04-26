#! /bin/bash

PRGNAME="sdl2-compat"

### SDL2 (Simple DirectMedia Layer Version 2)
# Современная библиотека SDL, которая позволяет играм и приложениям быстро
# рисовать графику, выводить звук и распознавать нажатия кнопок на любых
# устройствах. В отличие от первой версии, она полностью поддерживает ускорение
# видеокартой и современные экраны, делая картинку плавной.

# Required:    cmake
#              sdl3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                              \
    -D CMAKE_INSTALL_PREFIX=/usr   \
    -D CMAKE_BUILD_TYPE=Release    \
    -D CMAKE_SKIP_INSTALL_RPATH=ON \
    -D SDL2COMPAT_STATIC=OFF       \
    -D SDL2COMPAT_TESTS=OFF        \
    -W no-dev                      \
    -G Ninja .. || exit 1

ninja || exit 1

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# удалим статическую библиотеку
rm -vf "${TMP_DIR}/usr/lib/libSDL2_test.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simple DirectMedia Layer Version 2)
#
# Simple DirectMedia Layer Version 2 is a cross-platform library designed to
# provide low-level access to audio, keyboard, mouse, joystick, and graphics
# hardware via OpenGL
#
# Home page: https://libsdl.org/
# Download:  https://www.libsdl.org/release/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
