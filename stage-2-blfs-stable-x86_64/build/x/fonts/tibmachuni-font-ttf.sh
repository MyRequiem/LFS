#! /bin/bash

PRGNAME="tibmachuni-font-ttf"
ARCH_NAME="TibetanMachineUnicodeFont"
VERSION="1.901b"

### tibmachuni-font-ttf (Tibetan Machine Unicode font)
# Тибетский и Гималайский шрифты

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

SOURCES="${ROOT}/src"
unzip "${SOURCES}/${ARCH_NAME}.zip"
cd "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
mkdir -pv "${TMP_DIR}${TTF_FONT_DIR}"

cp ./*.ttf "${TMP_DIR}${TTF_FONT_DIR}"

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
# Package: ${PRGNAME} (Tibetan Machine Unicode font)
#
# The Tibetan & Himalayan Digital Library's Unicode character based "Tibetan
# Machine Uni" OpenType font for writing Tibetan, Dzongkha and Ladakhi in dbu
# can script with full support for the Sanskrit combinations found in chos-skad
# texts.
#
# Home page: http://luc.devroye.org/fonts-45725.html
# Download:  https://mirrors.slackware.com/slackware/slackware64-14.2/source/x/${PRGNAME}/${ARCH_NAME}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
