#! /bin/bash

PRGNAME="imwheel"

### IMWheel (a mouse wheel and stick interpreter for X Windows)
# Утилита для управления скоростью прокрутки колеса мыши.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключаем отображение конфигуратора при движении мыши и прокрутке колеса (его
# можно вызвать с параметром '-с')
patch --verbose -p1 \
    -i "${SOURCES}/${PRGNAME}-${VERSION}-noautoconfigurator.patch" || exit 1

./configure                 \
    --prefix=/usr           \
    --sysconfdir=/etc       \
    --localstatedir=/var    \
    --mandir=/usr/share/man \
    --infodir=/usr/share/info || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}" ETCDIR="${TMP_DIR}/etc/X11/${PRGNAME}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a mouse wheel and stick interpreter for X Windows)
#
# IMWheel is a universal mouse wheel and mouse stick translator for the X
# Windows System. Using either a special version of gpm and it's /dev/gpmwheel
# FIFO, or the support for a ZAxis on the mouse built into some servers, such
# as XFree86. Utilizing the input from gpm or X Windows, imwheel translates
# mouse wheel and mouse stick actions into keyboard events using the XTest
# extension to X. Use xdpyinfo for information on the supported extensions in
# your X server
#
# Home page: http://${PRGNAME}.sourceforge.net/
# Download:  http://downloads.sourceforge.net/project/${PRGNAME}/${PRGNAME}-source/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
