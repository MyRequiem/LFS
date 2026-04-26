#! /bin/bash

PRGNAME="x264"

### x264 (free h264/avc encoder)
# Самая популярная библиотека для сжатия видео в формат H.264 (MPEG-4 AVC),
# которая позволяет делать видеофайлы компактными при сохранении высокого
# качества. Она признана стандартом индустрии и используется почти везде: от
# стриминга на YouTube до видеозвонков и записи экрана.

# Required:    no
# Recommended: nasm
# Optional:    ffms2              (https://github.com/FFMS/ffms2)
#              gpac или liblsmash (https://github.com/gpac/gpac/releases/) (https://github.com/l-smash/l-smash)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# отключаем создание кодировщика командной строки, который является избыточным,
# поскольку для большинства форматов требуется FFmpeg
#    --disable-cli
./configure         \
    --prefix=/usr   \
    --enable-shared \
    --disable-cli || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (free h264/avc encoder)
#
# x264 package provides a library for encoding video streams into the
# H.264/MPEG-4 AVC format
#
# Home page: https://www.videolan.org/developers/${PRGNAME}.html
# Download:  https://anduin.linuxfromscratch.org/BLFS/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
