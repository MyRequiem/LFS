#! /bin/bash

PRGNAME="indic-fonts-ttf"
ARCH_NAME="ttf-indic-fonts"

### dejavu-fonts-ttf (DejaVu fonts)
# Семейство шрифтов, основанное на шрифтах Bitstream Vera

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d _ -f 1 | rev)"

BUILD_DIR="/tmp/build-${ARCH_NAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}_${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
ETC_FONTS="/etc/fonts"
mkdir -pv "${TMP_DIR}"{"${TTF_FONT_DIR}","${ETC_FONTS}"/conf.{d,avail}}

find . -type f -name "*.ttf" \
    -exec cp -a {} "${TMP_DIR}${TTF_FONT_DIR}" \;
find . -type f -name "*.conf" \
    -exec cp -a {} "${TMP_DIR}${ETC_FONTS}/conf.avail" \;

cd "${TMP_DIR}${ETC_FONTS}/conf.avail" || exit 1
for CONF in *; do
    (
        cd "${TMP_DIR}${ETC_FONTS}/conf.d" || exit 1
        ln -sf "../conf.avail/${CONF}" "${CONF}"
    )
done

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
# Package: ${PRGNAME} (DejaVu fonts)
#
# The DejaVu fonts are a font family based on the Bitstream Vera Fonts. Its
# purpose is to provide a wider range of characters while maintaining the
# original look and feel.
#
# Home page: https://launchpad.net/ttf-indic-fonts
# Download:  https://mirrors.slackware.com/slackware/slackware64-14.2/source/x/${ARCH_NAME}/${ARCH_NAME}_${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
