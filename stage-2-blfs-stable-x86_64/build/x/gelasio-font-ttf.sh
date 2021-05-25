#! /bin/bash

PRGNAME="gelasio-font-ttf"
ARCH_NAME="$(echo ${PRGNAME} | cut -d - -f 1)"
VERSION="13042020"

### Gelasio (Gelasio TTF font)
# Шрифт совместимый со шрифтом MS Georgia и fontconfig будет его использовать
# если запрошивается MS Georgia, но он не устанавлен.

# Required:    xorg-applications
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
unzip -d "${ARCH_NAME}-${VERSION}" "${SOURCES}/${ARCH_NAME}.zip" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
mkdir -pv "${TMP_DIR}${TTF_FONT_DIR}"

cp "${ARCH_NAME}-${VERSION}"/*.ttf "${TMP_DIR}${TTF_FONT_DIR}"

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
# Package: ${PRGNAME} (Gelasio TTF font)
#
# Gelasio is metrically compatible with MS Georgia and fontconfig will use it
# if ever Georgia is requested but not installed.
#
# Home page: https://fontlibrary.org/en/font/${ARCH_NAME}
# Download:  https://fontlibrary.org/assets/downloads/${ARCH_NAME}/4d610887ff4d445cbc639aae7828d139/${ARCH_NAME}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
