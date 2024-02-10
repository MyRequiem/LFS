#! /bin/bash

PRGNAME="ipaex-fonts-ttf"
ARCH_NAME="IPAexfont"

### IPAex fonts (Japanese fonts by IPA)
# Японский шрифт фиксированной ширины

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}*.zip" 2>/dev/null | sort | head -n 1 | rev | \
    cut -d . -f 2- | cut -d t -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

unzip "${SOURCES}/${ARCH_NAME}${VERSION}".zip || exit 1
cd "${ARCH_NAME}${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}${INSTALL_DIR}"

chown root:root ./*
chmod 644 ipaex{g,m}.ttf
cp ipaex{g,m}.ttf "${TMP_DIR}${INSTALL_DIR}"

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
# Package: ${PRGNAME} (Japanese fonts by IPA)
#
# IPAex fonts feature fixed width glyphs for Japanese characters and
# proportional width glyphs for Western characters. They were designed as an
# implementation of JIS X 0213:2004 standard.
#
# Home page: https://moji.or.jp/ipafont/
# Download:  https://moji.or.jp/wp-content/ipafont/${ARCH_NAME}/${ARCH_NAME}${VERSION}.zip
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
