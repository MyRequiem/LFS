#! /bin/bash

PRGNAME="terminus-font"

### Шрифты для терминала linux
# Пакет описан в BLFS, но установим его сейчас для последующей настройки
# нормального шрифта в чистой консоли в файле /etc/sysconfig/console

# Home page: http://terminus-font.sourceforge.net
# Download:  https://netcologne.dl.sourceforge.net/project/terminus-font/terminus-font-4.48/terminus-font-4.48.tar.gz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr

# собираем только PSF шрифты для чистого терминала. В пакете присутствуют еще
# PCF шрифты для X Window System, но для их сборки нужна утилита bdftopcf
# входящая в состав иксов, которые пока не установлены
make psf

make install-psf
make install-psf DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (font for linux terminal)
#
# Terminus Font is a clean, fixed width bitmap font, designed for long (8 and
# more hours per day) work with computers. Version 4.48 contains 1354
# characters, covers about 120 language sets and supports
# ISO8859-1/2/5/7/9/13/15/16, Paratype-PT154/PT254, KOI8-R/U/E/F, Esperanto,
# many IBM, Windows and Macintosh code pages, as well as the IBM VGA, vt100 and
# xterm pseudographic characters.
#
# Home page: http://terminus-font.sourceforge.net
# Download:  https://netcologne.dl.sourceforge.net/project/${PRGNAME}/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
