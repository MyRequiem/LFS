#! /bin/bash

PRGNAME="sdl"
ARCH_NAME="$(echo "${PRGNAME}" | awk '{print toupper($0)}')"

### SDL (Simple DirectMedia Layer library)
# Кроссплатформенная мультимедийная библиотека, реализующая единый программный
# интерфейс (API) к графической подсистеме через OpenGL и 2D framebuffer,
# звуковым устройствам, средствам ввода (клавиатуре, мыши, джойстику) для
# широкого спектра платформ. Данная библиотека активно используется при
# написании кроссплатформенных мультимедийных программ (в основном игр)

# Required:    no
# Recommended: xorg-libraries
# Optional:    alsa-lib
#              alsa-tools
#              alsa-utils
#              alsa-plugins
#              alsa-oss
#              aalib
#              glu
#              nasm
#              pulseaudio
#              pth
#              X Window System
#              directfb        (https://src.fedoraproject.org/repo/pkgs/directfb/)
#              ggi             (http://ibiblio.org/ggicore/)
#              libcaca         (http://caca.zoy.org/wiki/libcaca)
#              picogui         (http://picogui.org/)
#              svgalib         (https://www.svgalib.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOCS="false"

# исправим ошибку сборки с libx11 >= 1.6.0
sed -e '/_XData32/s:register long:register _Xconst long:' \
    -i src/video/x11/SDL_x11sym.h || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

if [[ "x${DOCS}" == "xtrue" ]]; then
    DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
    install -v -m755 -d "${TMP_DIR}${DOC_PATH}/html"
    install -v -m644    docs/html/*.html "${TMP_DIR}${DOC_PATH}/html"
fi

# тестирование
# cd test     || exit 1
# ./configure || exit 1
# make        || exit 1
#
# затем нужно будет вручную запустить все тестовые программы в директории
# ./test

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Simple DirectMedia Layer library)
#
# This is the Simple DirectMedia Layer, a generic API that provides low level
# access to audio, keyboard, mouse, joystick, 3D hardware via OpenGL, and 2D
# framebuffer across multiple platforms.
#
# Home page: https://www.libsdl.org/
# Download:  https://www.libsdl.org/release/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
