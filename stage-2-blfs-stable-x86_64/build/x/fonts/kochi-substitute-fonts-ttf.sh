#! /bin/bash

PRGNAME="kochi-substitute-fonts-ttf"
ARCH_NAME="$(echo ${PRGNAME} | cut -d - -f 1,2)"

### Kochi Substitute fonts (Kochi Substitute Japanese fonts)
# Шрифты Kochi Substitute это первые по-настоящему свободные японские шрифты
# (ранее они были заимствованы из коммерческого шрифта)

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
# Package: ${PRGNAME} (Kochi Substitute Japanese fonts)
#
# The Kochi Substitute fonts were the first truly libre Japanese fonts (the
# earlier Kochi fonts were allegedly plagiarized from a commercial font)
#
# Home page: https://osdn.net/projects/efont/releases/p1357
# Download:  https://jaist.dl.osdn.jp/efont/5411/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
