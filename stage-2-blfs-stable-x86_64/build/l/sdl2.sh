#! /bin/bash

PRGNAME="sdl2"
ARCH_NAME="$(echo "${PRGNAME}" | awk '{print toupper($0)}')"

### SDL2 (Simple DirectMedia Layer Version 2)
# Кроссплатформенная библиотека, предназначенная для обеспечения
# низкоуровневого доступа к аудио, клавиатуре, мыши, джойстику и графическому
# оборудованию через OpenGL

# Required:    no
# Recommended: libxkbcommon
#              wayland-protocols
#              xorg-libraries
# Optional:    alsa-lib
#              alsa-plugins
#              alsa-utils
#              alsa-tools
#              alsa-oss
#              doxygen
#              ibus
#              nasm
#              pulseaudio
#              libsamplerate
#              directfb      (https://src.fedoraproject.org/repo/pkgs/directfb/)
#              fcitx         (https://fcitx-im.org/wiki/Fcitx_5)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOXYGEN="false"
# command -v doxygen &>/dev/null && DOXYGEN="true"

./configure \
    --prefix=/usr || exit 1

make || exit 1

if [[ "x${DOXYGEN}" == "xtrue" ]]; then
    pushd docs || exit 1
    doxygen    || exit 1
    popd       || exit 1
fi

make install DESTDIR="${TMP_DIR}"

# удалим статическую библиотеку
rm -v "${TMP_DIR}/usr/lib/libSDL2"*.a

if [[ "x${DOXYGEN}" == "xtrue" ]]; then
    DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -m755 -d        "${TMP_DIR}${DOC_PATH}/html"
    cp -Rv  docs/output/html/* "${TMP_DIR}${DOC_PATH}/html"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simple DirectMedia Layer Version 2)
#
# Simple DirectMedia Layer Version 2 is a cross-platform library designed to
# provide low-level access to audio, keyboard, mouse, joystick, and graphics
# hardware via OpenGL
#
# Home page: https://libsdl.org/
# Download:  http://www.libsdl.org/release/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
