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
source "${ROOT}/check_environment.sh"                  || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1,2 | rev | sed 's/-/_/')"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-"*.tar.?z* || exit 1
cd "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
ETC_FONTS="/etc/fonts"
mkdir -pv "${TMP_DIR}"{"${TTF_FONT_DIR}","${ETC_FONTS}"/conf.{d,avail}}

zcat "${SOURCES}/fixup-fontconfig-file.diff.gz" | patch -p1 --verbose || exit 1

find . -type f \( -name "*.ttf" -o  -name "*.ttc" \) \
    -exec cp -a {} "${TMP_DIR}${TTF_FONT_DIR}" \;

find . -type f -name "*.conf" \
    -exec cp -a {} "${TMP_DIR}${ETC_FONTS}/conf.avail" \;

cd "${TMP_DIR}${ETC_FONTS}/conf.d" || exit 1
ln -sf ../conf.avail/44-wqy-zenhei.conf 44-wqy-zenhei.conf

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
# Home page: http://wqy.sourceforge.net/en/
# Download:  https://mirrors.slackware.com/slackware/slackware64-14.2/source/x/${PRGNAME}/${ARCH_NAME}-${VERSION//_/-}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
