#! /bin/bash

PRGNAME="carlito-font-ttf"
ARCH_NAME="crosextrafonts-carlito"

### Carlito (Googles Carlito font)
# TTF шрифт от Google

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

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
# Package: ${PRGNAME} (Googles Carlito font)
#
# Carlito (created as another Chrome OS extra font) is metrically compatible
# with MS Calibri and can be used if you have to edit a document which somebody
# started in Microsoft Office using Calibri and then return it to them.
#
# Home page: https://bugs.chromium.org/p/chromium/issues/detail?id=280557
# Download:  http://gsdview.appspot.com/chromeos-localmirror/distfiles/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
