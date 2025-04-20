#! /bin/bash

PRGNAME="faac"

### FAAC (Freeware Advanced Audio Coder)
# Кодировщик для схемы сжатия звука с потерями, указанной в MPEG-2 Part 7 и
# MPEG-4 Part 3 и известной как Advanced Audio Coding (AAC). Этот кодировщик
# полезен для создания файлов, которые можно воспроизводить на iPod. Более
# того, iPod не поддерживает другие схемы сжатия звука в видео файлах.

# Required:    no
# Recommended: no
# Optional:    --- для тестирования кодировщика ---
#              alsa-utils (утилита aplay для тестрования декодера)
#              faad2

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

PKG_VERSION="${VERSION//_/.}"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${PKG_VERSION}"
mkdir -pv "${TMP_DIR}"

./bootstrap &&
./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

# базовая функциональность может быть протестирована путем кодирования образца
# WAV-файла (устанавливается с пакетом alsa-utils) в формат MP4, обратного
# декодирования утилитой faad в .wav формат и последующего его воспроизведения
#    # faac -o Front_Left.mp4 /usr/share/sounds/alsa/Front_Left.wav
#    # faad Front_Left.mp4
#    # aplay Front_Left.wav

cat << EOF > "/var/log/packages/${PRGNAME}-${PKG_VERSION}"
# Package: ${PRGNAME} (Freeware Advanced Audio Coder)
#
# FAAC is an encoder for a lossy sound compression scheme specified in MPEG-2
# Part 7 and MPEG-4 Part 3 standards and known as Advanced Audio Coding (AAC).
# This encoder is useful for producing files that can be played back on iPod.
# Moreover, iPod does not understand other sound compression schemes in video
# files.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}
# Download:  https://github.com/knik0/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${PKG_VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
