#! /bin/bash

PRGNAME="terminus-font"

### Terminus Font (clean, fixed width bitmap font for linux console)
# Растровый шрифт с фиксированной шириной для чистой консоли linux

# Пакет упоминается в BLFS:
#    https://www.linuxfromscratch.org/blfs/view/12.3/postlfs/console-fonts.html
# Установим его сейчас для настройки шрифта ter-v14n в чистом терминале после
# установки System-V-configuration в файле /etc/sysconfig/console

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
FONTS="/usr/share/consolefonts"
mkdir -pv "${TMP_DIR}${FONTS}"

./configure \
    --prefix=/usr || exit 1

# собираем только PSF шрифты для чистого терминала. В пакете присутствуют еще
# PCF шрифты для X, но для их сборки нужна утилита bdftopcf входящая в состав
# иксов, которые пока не установлены
make psf || make -j1 psf || exit 1

# для установки всех собранных PSF шрифтов (~250 шт) запускаем:
# make install-psf DESTDIR="${TMP_DIR}"

# список шрифтов, которые будут установлены
FONT_LIST="\
ter-v14n.psf \
"
for FONT_NAME in ${FONT_LIST}; do
    gzip -vc "${FONT_NAME}" > "${TMP_DIR}${FONTS}/${FONT_NAME}.gz" ;
done

/bin/cp -vR "${TMP_DIR}"/* /

MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1,2)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (clean, fixed width bitmap font for linux console)
#
# Clean, fixed width bitmap font, designed for long (8 and more hours per day)
# work with computers. Version 4.48 contains 1354 characters, covers about 120
# language sets and supports ISO8859-1/2/5/7/9/13/15/16, Paratype-PT154/PT254,
# KOI8-R/U/E/F, Esperanto, many IBM, Windows and Macintosh code pages, as well
# as the IBM VGA, vt100 and xterm pseudographic characters.
#
# Sizes: 6x12, 8x14, 8x16, 10x18, 10x20, 11x22, 12x24, 14x28 and 16x32.
# Weights: normal and bold (except for 6x12), plus CRT VGA-bold for 8x14 and
# 8x16.
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}-${MAJ_VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
