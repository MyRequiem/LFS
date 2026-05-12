#! /bin/bash

PRGNAME="liberation-fonts-ttf"

### liberation-fonts-ttf (Liberation TTF Fonts)
# Набор шрифтов, которые по размеру и форме в точности повторяют популярные
# шрифты из Windows (Arial, Times New Roman). Это нужно, чтобы документы
# выглядели одинаково в разных системах.

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}${INSTALL_DIR}"

cp ./*.ttf "${TMP_DIR}${INSTALL_DIR}"

/bin/cp -vpR "${TMP_DIR}"/* /

# обновим индексы установленных шрифтов
cd "${INSTALL_DIR}" || exit 1
# создаем индекс файлов масштабируемых шрифтов
mkfontscale .
# создаем индекс файлов шрифтов в каталоге
mkfontdir .
# создаем файлы кэша информации о шрифтах для fontconfig
fc-cache -f

cp fonts.dir fonts.scale "${TMP_DIR}${INSTALL_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Liberation TTF Fonts)
#
# Liberation is the collective name of three TrueType font families: Liberation
# Sans, Liberation Serif and Liberation Mono. These fonts are metric-compatible
# with Arial, Times New Roman, and Courier New respectively.
#
# Home page: https://github.com/liberationfonts
# Download:  https://github.com/liberationfonts/liberation-fonts/files/7261482/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
