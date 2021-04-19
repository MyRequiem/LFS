#! /bin/bash

PRGNAME="liberation-fonts-ttf"

### liberation-fonts-ttf (Liberation TTF Fonts)
# Шрифты Liberation Sans, Liberation Serif и Liberation Mono

# Required:    xcursor-themes
#              xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
ETC_FONTS="/etc/fonts"
mkdir -pv "${TMP_DIR}"{"${TTF_FONT_DIR}","${ETC_FONTS}"/conf.{d,avail}}

cp ./*.ttf "${TMP_DIR}${TTF_FONT_DIR}"

cat << EOF > "${TMP_DIR}${ETC_FONTS}/conf.avail/60-liberation.conf"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<!-- \$Id: 60-liberation.conf,v 1.1 2008/03/27 11:14:42 root Exp root \$ -->
<fontconfig>
    <!-- Symlinking this file to /etc/fonts/conf.d/ will allow
         you to use liberation fonts instead of the microsoft truetype fonts.
         (from http://uwstopia.nl/blog/2007/05/free-your-fonts) -->

    <!-- Liberation fonts -->
    <match target="pattern">
        <test qual="any" name="family"><string>Times New Roman</string></test>
        <edit name="family" mode="assign"><string>Liberation Serif</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>Arial</string></test>
        <edit name="family" mode="assign"><string>Liberation Sans</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>Courier</string></test>
        <edit name="family" mode="assign"><string>Liberation Mono</string></edit>
    </match>
    <match target="pattern">
        <test qual="any" name="family"><string>Courier New</string></test>
        <edit name="family" mode="assign"><string>Liberation Mono</string></edit>
    </match>
</fontconfig>
EOF

cd "${TMP_DIR}${ETC_FONTS}/conf.d" || exit 1
ln -sf "../conf.avail/60-liberation.conf" 60-liberation.conf

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
# Package: ${PRGNAME} (Liberation TTF Fonts)
#
# Liberation is the collective name of three TrueType font families: Liberation
# Sans, Liberation Serif and Liberation Mono. These fonts are metric-compatible
# with Arial, Times New Roman, and Courier New respectively.
#
# Home page: https://github.com/liberationfonts
# Download:  https://releases.pagure.org/liberation-fonts/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
