#! /bin/bash

PRGNAME="wqy-zenhei-font-ttf"
ARCH_NAME="wqy-zenhei"

### wqy-zenhei-font-ttf (Wen Quan Yi Zen Hei CJK Font)
# Китайский шрифт

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-"*.tar.?z* || exit 1
cd "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
mkdir -pv "${TMP_DIR}${TTF_FONT_DIR}"

cp ./*.ttc "${TMP_DIR}${TTF_FONT_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

# обновим индексы установленных шрифтов
cd "${TTF_FONT_DIR}" || exit 1
# создаем индекс файлов масштабируемых шрифтов
mkfontscale .
# создаем индекс файлов шрифтов в каталоге
mkfontdir .
# создаем файлы кэша информации о шрифтах для fontconfig
fc-cache -f

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Wen Quan Yi Zen Hei CJK Font)
#
# The WenQuanYi Zen Hei font is a Chinese (or CJK) outline font with Hei Ti
# style (a sans-serif style) Hanzi glyphs. This font is developed for general
# purpose use of Chinese for formating, printing and on-screen display. This
# font is also targeted at platform independence and the utility for document
# exchange between various operating systems.
#
# Home page: http://wenq.org/wqy2/index.cgi?action=browse&id=Home&lang=en
# Download:  https://deac-riga.dl.sourceforge.net/project/wqy/${ARCH_NAME}/${VERSION}%20%28Fighting-state%20RC1%29/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
