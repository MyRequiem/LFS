#! /bin/bash

PRGNAME="sdl3"
ARCH_NAME="SDL3"

### SDL3 (Simple DirectMedia Layer Version 3)
# Новейшая версия библиотеки SDL, которая стала еще быстрее и удобнее для
# разработчиков, добавив продвинутую работу с графическими процессорами (GPU) и
# современными сенсорными экранами. Она избавляется от устаревшего кода прошлых
# лет, обеспечивая максимальную производительность для актуальных игр и
# приложений. Предназначенная для обеспечения низкоуровневого доступа к аудио,
# клавиатуре, мыши, джойстику и графическому оборудованию через OpenGL.

# Required:    cmake
# Recommended: alsa-lib
#              libusb
#              libxkbcommon
#              mesa
#              pipewire
#              pulseaudio
#              vulkan-loader
#              wayland-protocols
#              xorg-libraries
# Optional:    ibus
#              jack                     (https://jackaudio.org/)
#              sndio                    (https://sndio.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D SDL_TEST_LIBRARY=OFF      \
    -D SDL_STATIC=OFF            \
    -D SDL_RPATH=OFF             \
    -W no-dev                    \
    -G Ninja .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simple DirectMedia Layer Version 3)
#
# Simple DirectMedia Layer is a cross-platform development library designed to
# provide low-level access to audio, keyboard, mouse, joystick, and graphics
# hardware ia via OpenGL. It is used by video playback software, emulators, and
# games.
#
# Home page: https://libsdl.org/
# Download:  https://www.libsdl.org/release/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
