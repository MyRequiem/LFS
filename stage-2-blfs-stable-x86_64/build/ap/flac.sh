#! /bin/bash

PRGNAME="flac"

### FLAC (Free Lossless Audio Codec)
# Свободный аудиокодек, предназначенный для сжатия аудиоданных без потерь. В
# отличие от аудиокодеков, обеспечивающих сжатие с потерями (MP3, AAC, WMA, Ogg
# Vorbis, Opus), FLAC, как и любой другой lossless-кодек, не удаляет никакой
# информации из аудиопотока и подходит как для прослушивания музыки на
# высококачественной звуковоспроизводящей аппаратуре, так и для архивирования
# аудиоколлекций.

# Required:    no
# Recommended: no
# Optional:    libogg
#              docbook-utils
#              doxygen
#              valgrind

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                  \
    --prefix=/usr            \
    --disable-thorough-tests \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Free Lossless Audio Codec)
#
# FLAC stands for Free Lossless Audio Codec. Grossly oversimplified, FLAC is
# similar to MP3, but lossless, meaning that audio is compressed without losing
# any information. "Free" means that the specification of the stream format is
# in the public domain, and that neither the FLAC format nor any of the
# implemented encoding/decoding methods are covered by any patent. It also
# means that the sources for libFLAC and libFLAC++ are available under the LGPL
# and the sources for flac, metaflac, and the plugins are available under the
# GPL.
#
# Home page: https://xiph.org/${PRGNAME}/
# Download:  https://github.com/xiph/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
