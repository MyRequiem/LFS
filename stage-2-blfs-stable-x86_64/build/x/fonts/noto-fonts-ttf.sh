#! /bin/bash

PRGNAME="noto-fonts-ttf"
ARCH_NAME="noto-fonts-subset"

### Noto fonts (Googles Noto fonts)
# TTF шрифты от Google

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}/"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}/${PRGNAME}-${VERSION}"
cd "${BUILD_DIR}/${PRGNAME}-${VERSION}" || exit 1

tar -xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}${INSTALL_DIR}"

cp fonts/*.ttf "${TMP_DIR}${INSTALL_DIR}"

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
# Package: ${PRGNAME} (Googles Noto fonts)
#
# Noto is a collection of high-quality fonts with multiple weights and widths
# in sans, serif, mono, and other styles. The Noto fonts are perfect for
# harmonious, aesthetic, and typographically correct global communication, in
# more than 1,000 languages and over 150 writing systems. "Noto" means "I
# write, I mark, I note" in Latin. The name is also short for "no tofu", as the
# project aims to eliminate 'tofu': blank rectangles shown when no font is
# available for your text.
#
# Home page: https://github.com/googlefonts/noto-fonts/
# Download:  https://mirrors.slackware.com/slackware/slackware64-current/source/x/${PRGNAME}/${ARCH_NAME}-${VERSION}.tar.lz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
