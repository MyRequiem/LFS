#! /bin/bash

PRGNAME="sazanami-fonts-ttf"
ARCH_NAME="sazanami"

### sazanami-fonts-ttf (Japanese TrueType Unicode fonts)
# Шрифты sazanami содержат японские иероглифы Hiragana, Katakana и Kanji/Han

# Required:    xcursor-themes
#              xorg-applications
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
# Package: ${PRGNAME} (Japanese TrueType Unicode fonts)
#
# The Sazanami fonts contain Hiragana, Katakana, and Kanji/Han Ideographs.
#
# Home page: http://sourceforge.jp/projects/efont/
# Download:  https://mirrors.bfsu.edu.cn/osdn//efont/10087/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
