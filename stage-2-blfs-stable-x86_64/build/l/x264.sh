#! /bin/bash

PRGNAME="x264"

### x264 (free h264/avc encoder)
# Библиотека для кодирования видеопотоков в формат H.264/MPEG-4 AVC

# Required:    no
# Recommended: nasm
# Optional:    ffms2
#              gpac (https://github.com/gpac/gpac/releases/) или liblsmash (https://github.com/l-smash/l-smash)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

NASM="--disable-asm"
command -v nasm &>/dev/null && NASM="--enable-asm"

# отключаем создание кодировщика командной строки, который является избыточным,
# поскольку для большинства форматов требуется FFmpeg
#    --disable-cli
./configure         \
    --prefix=/usr   \
    --enable-shared \
    "${NASM}"       \
    --disable-cli || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (free h264/avc encoder)
#
# x264 package provides a library for encoding video streams into the
# H.264/MPEG-4 AVC format
#
# Home page: http://www.videolan.org/developers/${PRGNAME}.html
# Download:  http://anduin.linuxfromscratch.org/BLFS/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
