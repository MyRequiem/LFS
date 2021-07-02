#! /bin/bash

PRGNAME="faad2"

### FAAD2 (MPEG2 and MPEG-4 AAC decoder)
# Декодер для схемы сжатия звука с потерями, указанной в MPEG-2 Part 7 и MPEG-4
# Part 3, известной как Advanced Audio Coding (AAC)

# Required:    no
# Recommended: no
# Optional:    alsa-utils (для тестрования декодера)
#              faac       (для тестрования декодера)

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

# пакет не имеет набора тестов однако базовая функциональность может быть
# протестирована путем кодирования образца WAV-файла (который устанавливается с
# пакетом alsa-utils) в формат MP4, декодированием его обратно в WAV-файл с
# последующим воспроизведением
#    # faac -o Front_Left.mp4 /usr/share/sounds/alsa/Front_Left.wav
#    # faad Front_Left.mp4
#    # aplay Front_Left.wav
#
#    # faad -o sample.wav "${SOURCES}/sample.aac"
#       должно отобразиться сообщение об авторских правах и информация о файле:
#
#           sample.aac file info:
#           ADTS, 4.608 sec, 13 kbps, 16000 Hz
#
#           ---------------------
#           | Config:  2 Ch       |
#           ---------------------
#           | Ch |    Position    |
#           ---------------------
#           | 00 | Left front     |
#           | 01 | Right front    |
#           ---------------------
#
#    воспроизведем файл
#    # aplay sample.wav

cat << EOF > "/var/log/packages/${PRGNAME}-${PKG_VERSION}"
# Package: ${PRGNAME} (MPEG2 and MPEG-4 AAC decoder)
#
# FAAD2 is a decoder for a lossy sound compression scheme specified in MPEG-2
# Part 7 and MPEG-4 Part 3 standards and known as Advanced Audio Coding (AAC)
#
# Home page: https://github.com/knik0/${PRGNAME}
# Download:  https://github.com/knik0/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${PKG_VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
