#! /bin/bash

PRGNAME="noto-fonts-ttf"

### Noto fonts (Googles Noto fonts)
# TTF шрифты от Google

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

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
# Download:  https://github.com/MyRequiem/LFS/raw/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
