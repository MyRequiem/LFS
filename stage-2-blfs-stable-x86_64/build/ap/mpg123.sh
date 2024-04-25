#! /bin/bash

PRGNAME="mpg123"

### mpg123 (a command-line mp3 player)
# Консольный MP3-плеер

# Required:    no
# Recommended: alsa-lib
# Optional:    pulseaudio
#              sdl
#              jack         (https://jackaudio.org/)
#              openal       (https://openal.org/)
#              portaudio    (https://www.portaudio.com/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a command-line mp3 player)
#
# The mpg123 package contains a console-based MP3 player. It claims to be the
# fastest MP3 decoder for Unix.
#
# Home page: http://${PRGNAME}.org/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
