#! /bin/bash

PRGNAME="microsoft-webcore-fonts-ttf"
ARCH_NAME="webcore-fonts"

### Microsoft Webcore Fonts (Microsoft's core fonts for the web)

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/config_file_processing.sh"               || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
ETC_FONTS="/etc/fonts"
mkdir -pv "${TMP_DIR}"{${TTF_FONT_DIR},${ETC_FONTS}}

cp "${ARCH_NAME}/fonts"/* "${TMP_DIR}${TTF_FONT_DIR}"
cp "${ARCH_NAME}/vista"/* "${TMP_DIR}${TTF_FONT_DIR}"

FONT_LOCAL_CONF="${ETC_FONTS}/local.conf"
cat << EOF > "${TMP_DIR}${FONT_LOCAL_CONF}"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <!-- Disable embedded bitmaps in fonts like Calibri -->
    <match target="font" >
        <edit name="embeddedbitmap" mode="assign">
            <bool>false</bool>
        </edit>
    </match>
</fontconfig>
EOF

if [ -f "${FONT_LOCAL_CONF}" ]; then
    mv "${FONT_LOCAL_CONF}" "${FONT_LOCAL_CONF}.old"
fi

/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${FONT_LOCAL_CONF}"

# обновим индексы установленных шрифтов
cd "${TTF_FONT_DIR}" || exit 1
# создаем индекс файлов масштабируемых шрифтов
mkfontscale .
# создаем индекс файлов шрифтов в каталоге
mkfontdir .
# создаем файлы кэша информации о шрифтах для fontconfig
fc-cache -f

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Microsoft's core fonts for the web)
#
# The Microsoft Core Fonts include:
#    * Microsoft's core fonts for the web
#    * Microsoft Tahoma
#    * Microsoft's fonts for Windows Vista
#
# Home page: http://avi.alkalay.net/linux/docs/font-howto/Font.html#msfonts
# Download:  http://avi.alkalay.net/software/${ARCH_NAME}/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
