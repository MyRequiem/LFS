#! /bin/bash

PRGNAME="libsndfile"

### libsndfile (C library for reading and writing wav files)
# Библиотека для чтения и записи аудиофайлов. Понимает десятки форматов звука,
# от профессиональных до самых простых.

# Required:    no
# Recommended: flac
#              opus
#              libvorbis
# Optional:    alsa-lib
#              lame
#              mpg123
#              speex

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим для сборки с GCC >=15
sed -i '/typedef enum/,/bool ;/d' src/ALAC/alac_{en,de}coder.c

./configure       \
    --prefix=/usr \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# отключим тесты Opus, которые не будут работать в opus >=1.6.1
# sed '/ogg_opus/,+1s/HAVE_[A-Z_]*/0/' -i tests/lossy_comp_test.c || exit 1
# make check

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C library for reading and writing wav files)
#
# Libsndfile is a C library for reading and writing files containing sampled
# audio data (such as MS Windows WAV and Apple/SGI AIFF format).
#
# Home page: http://www.mega-nerd.com/${PRGNAME}/
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
