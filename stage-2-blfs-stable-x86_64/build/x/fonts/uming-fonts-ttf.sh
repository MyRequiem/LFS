#! /bin/bash

PRGNAME="uming-fonts-ttf"
ARCH_NAME="ttf-arphic-uming"

### UMing fonts (sets of Chinese Ming fonts)
# Коллекция шрифтов Chinese Unicode TrueType в стиле Mingti AR PL UMing

# Required:    xorg-applications
#              fontconfig
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 4- | cut -d _ -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

mkdir "${ARCH_NAME}-${VERSION}"
tar -C "${ARCH_NAME}-${VERSION}" \
    -xvf "${SOURCES}/${ARCH_NAME}_${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
TTF_FONT_DIR="/usr/share/fonts/X11/TTF/"
ETC_FONTS="/etc/fonts"
mkdir -pv "${TMP_DIR}"{"${TTF_FONT_DIR}","${ETC_FONTS}"/conf.{d,avail}}

cp ./*.ttc  "${TMP_DIR}${TTF_FONT_DIR}"
cp ./*.conf "${TMP_DIR}${ETC_FONTS}/conf.avail"

# исправим конфиги
#    /etc/fonts/conf.avail/25-ttf-arphic-uming-bitmaps.conf
#    /etc/fonts/conf.avail/41-ttf-arphic-uming.conf
CONF="${ETC_FONTS}/conf.avail/25-ttf-arphic-uming-bitmaps.conf"
cat << EOF > "${TMP_DIR}${CONF}"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

    <match target="font">
        <test name="family">
            <string>AR PL UMing CN</string>
        </test>
        <test name="family">
            <string>AR PL UMing HK</string>
        </test>
        <test name="family">
            <string>AR PL UMing TW</string>
        </test>
        <test name="family">
            <string>AR PL UMing TW MBE</string>
        </test>
        <edit name="antialias"><bool>false</bool></edit>
        <edit name="hinting"><bool>true</bool></edit>
        <edit name="autohint"><bool>false</bool></edit>
    </match>

    <match target="font">
        <test name="family">
            <string>AR PL UMing CN</string>
        </test>
        <test name="family">
            <string>AR PL UMing HK</string>
        </test>
        <test name="family">
            <string>AR PL UMing TW</string>
        </test>
        <test name="family">
            <string>AR PL UMing TW MBE</string>
        </test>
        <test name="pixelsize" compare="more_eq"><int>17</int></test>
        <edit name="antialias" mode="assign"><bool>true</bool></edit>
        <edit name="hinting" mode="assign"><bool>true</bool></edit>
    </match>

</fontconfig>
EOF

CONF="${ETC_FONTS}/conf.avail/41-ttf-arphic-uming.conf"
cat << EOF > "${TMP_DIR}${CONF}"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

<!--
  Serif faces
 -->
    <alias>
        <family>AR PL ShanHeiSun Uni</family>
        <default><family>serif</family></default>
    </alias>
    <alias>
        <family>AR PL ShanHeiSun Uni MBE</family>
        <default><family>serif</family></default>
    </alias>
    <alias>
        <family>AR PL UMing CN</family>
        <default><family>serif</family></default>
    </alias>
    <alias>
        <family>AR PL UMing HK</family>
        <default><family>serif</family></default>
    </alias>
    <alias>
        <family>AR PL UMing TW</family>
        <default><family>serif</family></default>
    </alias>
    <alias>
        <family>AR PL UMing TW MBE</family>
        <default><family>serif</family></default>
    </alias>
<!--
  Sans-serif faces
 -->
    <alias>
        <family>AR PL ShanHeiSun Uni</family>
        <default><family>sans-serif</family></default>
    </alias>
    <alias>
        <family>AR PL ShanHeiSun Uni MBE</family>
        <default><family>sans-serif</family></default>
    </alias>
    <alias>
        <family>AR PL UMing CN</family>
        <default><family>sans-serif</family></default>
    </alias>
    <alias>
        <family>AR PL UMing HK</family>
        <default><family>sans-serif</family></default>
    </alias>
    <alias>
        <family>AR PL UMing TW</family>
        <default><family>sans-serif</family></default>
    </alias>
    <alias>
        <family>AR PL UMing TW MBE</family>
        <default><family>sans-serif</family></default>
    </alias>
<!--
  Monospace faces
 -->
     <alias>
        <family>AR PL ShanHeiSun Uni</family>
        <default><family>monospace</family></default>
    </alias>
     <alias>
        <family>AR PL ShanHeiSun Uni MBE</family>
        <default><family>monospace</family></default>
    </alias>
     <alias>
        <family>AR PL UMing CN</family>
        <default><family>monospace</family></default>
    </alias>
     <alias>
        <family>AR PL UMing HK</family>
        <default><family>monospace</family></default>
    </alias>
     <alias>
        <family>AR PL UMing TW</family>
        <default><family>monospace</family></default>
    </alias>
     <alias>
        <family>AR PL UMing TW MBE</family>
        <default><family>monospace</family></default>
    </alias>

</fontconfig>
EOF

# создаем ссылки в /etc/fonts/conf.d/
cd "${TMP_DIR}${ETC_FONTS}/conf.avail" || exit 1
for CONF in *; do
    (
        cd "${TMP_DIR}${ETC_FONTS}/conf.d" || exit 1
        ln -sf "../conf.avail/${CONF}" "${CONF}"
    )
done

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
# Package: ${PRGNAME} (sets of Chinese Ming fonts)
#
# Chinese Unicode TrueType font collection Mingti style "AR PL UMing" is a
# high-quality Chinese Unicode TrueType font collection (uming.ttc) derieved
# from the original "AR PL Mingti2L Big5" and "AR PL SungtiL GB" fonts
# generously provided by Arphic Technology to the Free Software community under
# the "Arphic Public License".
#
# Home page: http://www.arphic.com.tw/
# Download:  http://ponce.cc/slackware/sources/repo/${ARCH_NAME}_${VERSION}.orig.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
