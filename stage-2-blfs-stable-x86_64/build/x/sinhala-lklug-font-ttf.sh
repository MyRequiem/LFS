#! /bin/bash

PRGNAME="sinhala-lklug-font-ttf"
TTF_FONT_NAME="sinhala_lklug"
VERSION="20060929"

### sinhala-lklug-font-ttf (Sinhala Unicode TrueType font)
# Unicode шрифт Шри-Ланки

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1

TMP_DIR="/tmp/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
mkdir -pv "${TMP_DIR}${TTF_FONT_DIR}"

cp ${ROOT}/src/sinhala_lklug.ttf "${TMP_DIR}${TTF_FONT_DIR}"

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
# Package: ${PRGNAME} (Sinhala Unicode TrueType font)
#
# This is a free Sri Lankan 'Sinhala' Unicode font. Its development was
# initiated by the LK LUG in 2003.
#
# Home page: http://sinhala.sourceforge.net/
# Download:  https://mirrors.slackware.com/slackware/slackware64-14.2/source/x/${TTF_FONT_NAME}-font-ttf/${TTF_FONT_NAME}.ttf
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
