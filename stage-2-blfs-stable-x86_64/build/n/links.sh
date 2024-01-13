#! /bin/bash

PRGNAME="links"

### Links (WWW browser for the console)
# Консольный WWW браузер, поддерживающий цвета, корректный рендеринг таблиц,
# фоновую загрузку, фреймы, JavaScript и меню конфигурации интерфейса. С
# использованием фреймбуфера или SVGAlib поддерживается графический вывод.

# Required:    no
# Recommended: libevent
# Optional:    gpm                      (для поддержики мыши в графическом режиме с фреймбуффером)
#              svgalib                  (http://www.svgalib.org/)
#              directfb                 (http://pkgs.fedoraproject.org/repo/pkgs/directfb/)
#              Graphical Environments
#              libpng
#              libjpeg-turbo
#              librsvg
#              libtiff

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

./configure           \
    --prefix=/usr     \
    --enable-graphics \
    --mandir=/usr/share/man || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# документация
install -v -m644 doc/links_cal/* KEYS BRAILLE_HOWTO "${TMP_DIR}${DOCS}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (WWW browser for the console)
#
# Links is a console mode WWW browser, supporting colors, correct table
# rendering, background downloading, frames, Javascript, and a menu driven
# configuration interface. The default is text output, but graphical output
# (using -g) is also supported using the Linux framebuffer console or SVGAlib.
#
# Home page: http://links.twibright.com/
# Download:  http://links.twibright.com/download/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
