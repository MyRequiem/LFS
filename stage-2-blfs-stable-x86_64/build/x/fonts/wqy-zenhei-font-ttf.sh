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
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INSTALL_DIR="/usr/share/fonts/${PRGNAME}/"
mkdir -pv "${TMP_DIR}"{"${INSTALL_DIR}",/etc/fonts/conf.{d,avail}}

cp wqy-zenhei.ttc "${TMP_DIR}${INSTALL_DIR}"

# конфиги
cat "${SOURCES}/44-wqy-zenhei-upstream-orig.conf" > \
    "${TMP_DIR}/etc/fonts/conf.avail/44-wqy-zenhei-upstream-orig.conf"

cat "${SOURCES}/64-wqy-zenhei.conf" > \
    "${TMP_DIR}/etc/fonts/conf.avail/64-wqy-zenhei.conf"

cat "${SOURCES}/66-wqy-zenhei-sharp.conf" > \
    "${TMP_DIR}/etc/fonts/conf.avail/66-wqy-zenhei-sharp.conf"

(
    cd "${TMP_DIR}/etc/fonts/conf.d/" || exit 1
    ln -svf ../conf.avail/44-wqy-zenhei-upstream-orig.conf \
        44-wqy-zenhei-upstream-orig.conf
    ln -svf ../conf.avail/64-wqy-zenhei.conf 64-wqy-zenhei.conf
    ln -svf ../conf.avail/66-wqy-zenhei-sharp.conf 66-wqy-zenhei-sharp.conf
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
