#! /bin/bash

PRGNAME="gtick"

### GTick (A Metronome Application for GNU Linux)
# Метроном, написанный для GNU/Linux и других UN*X-подобных систем. Использует
# GTK+ и OSS (ALSA совместимый). Является частью проекта GNU
# (http://www.gnu.org/)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
ICONS="/usr/share/icons/hicolor/48x48/apps"
mkdir -pv "${TMP_DIR}${ICONS}"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

cp "${SOURCES}/${PRGNAME}.png" "${TMP_DIR}${ICONS}/${PRGNAME}.png"
chmod 644 "${TMP_DIR}${ICONS}/${PRGNAME}.png"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A Metronome Application for GNU Linux)
#
# GTick is a metronome application written for GNU/Linux and other UN*X-like
# operting systems supporting different meters (Even, 2/4, 3/4, 4/4 and more)
# and speeds ranging from 10 to 1000 bpm. It utilizes GTK+ and OSS (ALSA
# compatible). It is part of the GNU Project (http://www.gnu.org/)
#
# Home page: https://www.antcom.de/${PRGNAME}/
# Download:  https://www.antcom.de/${PRGNAME}/download/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
