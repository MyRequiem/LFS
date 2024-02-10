#! /bin/bash

PRGNAME="wqy-zenhei-font-ttf"
ARCH_NAME="wqy-zenhei"

### wqy-zenhei-font-ttf (Wen Quan Yi Zen Hei CJK Font)
# Шрифты WenQuanYi Zen Hei

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}"{"${INSTALL_DIR}",/etc/fonts/conf.{d,avail}}

cp wqy-zenhei.ttc "${TMP_DIR}${INSTALL_DIR}"

cp 43-wqy-zenhei-sharp.conf 44-wqy-zenhei.conf \
    "${TMP_DIR}/etc/fonts/conf.avail/"
chown root:root "${TMP_DIR}/etc/fonts/conf.avail"/*
chmod 644       "${TMP_DIR}/etc/fonts/conf.avail"/*

(
    cd "${TMP_DIR}/etc/fonts/conf.d/" || exit 1
    ln -svf ../conf.avail/43-wqy-zenhei-sharp.conf 43-wqy-zenhei-sharp.conf
    ln -svf ../conf.avail/44-wqy-zenhei.conf       44-wqy-zenhei.conf
)


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
# Package: ${PRGNAME} (Wen Quan Yi Zen Hei CJK Font)
#
# The WenQuanYi Zen Hei font is a Chinese (or CJK) outline font with Hei Ti
# style (a sans-serif style) Hanzi glyphs. This font is developed for general
# purpose use of Chinese for formating, printing and on-screen display. This
# font is also targeted at platform independence and the utility for document
# exchange between various operating systems.
#
# Home page: https://sourceforge.net/projects/wqy/files/${ARCH_NAME}/
# Download:  https://altushost-swe.dl.sourceforge.net/project/wqy/${ARCH_NAME}/${VERSION}%20%28Fighting-state%20RC1%29/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
