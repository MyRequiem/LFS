#! /bin/bash

PRGNAME="oxygen-fonts-ttf"
ARCH_NAME="oxygen-fonts"

### Oxygen fonts (oxygen fonts)
# TTF Шрифты Oxygen

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

find . -type f -name "*.ttf" -exec cp {} "${TMP_DIR}${TTF_FONT_DIR}" \;

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
# Package: ${PRGNAME} (oxygen fonts)
#
# When KDE Frameworks 5 was first released, it used the Oxygen fonts which were
# designed for integrated use with the KDE desktop. Those fonts are no-longer
# actively maintained, so KDE made a decision to switch to Noto fonts, but for
# the moment they are still required by 'startkde'.
#
# Home page: https://download.kde.org/Attic/plasma/${VERSION}/
# Download:  http://download.kde.org/stable/plasma/${VERSION}/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
