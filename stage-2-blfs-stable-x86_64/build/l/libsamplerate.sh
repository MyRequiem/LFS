#! /bin/bash

PRGNAME="libsamplerate"

### libsamplerate (a Sample Rate Converter for audio)
# Конвертер частоты дискретизации для аудио. Например, преобразование частоты
# дискретизации CD 44,1 кГц в 48 кГц для DAT-плееров

# Required:    no
# Recommended: no
# Optional:    alsa-lib
#              libsndfile
#              fftw         (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure          \
    --prefix=/usr    \
    --disable-static \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a Sample Rate Converter for audio)
#
# Secret Rabbit Code (aka libsamplerate) is a Sample Rate Converter for audio.
# One example of where such a thing would be useful is converting audio from
# the CD sample rate of 44.1kHz to the 48kHz sample rate used by DAT players.
# SRC is capable of arbitrary and time varying conversions. SRC provides a
# small set of converters to allow quality to be traded off against computation
# cost.
#
# Home page: http://www.mega-nerd.com/SRC/
# Download:  https://github.com/libsndfile/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
