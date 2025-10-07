#! /bin/bash

PRGNAME="libvorbis"

### libvorbis (Ogg Vorbis library)
# General Audio Compression Codec, широко известный как Ogg Vorbis.
# Используется для создания (кодирования) и воспроизведения (декодирования)
# звуковых файлов.

# Required:    libogg
# Recommended: no
# Optional:    --- для документации ---
#              doxygen
#              texlive or install-tl-unx (для сборки документации в формате pdf)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make -j1 check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Ogg Vorbis library)
#
# The libvorbis package contains a general purpose audio and music encoding
# format (General Audio Compression Codec, commonly known as Ogg Vorbis). This
# is useful for creating (encoding) and playing (decoding) sound in an open
# (patent free) format.
#
# Home page: https://www.xiph.org/vorbis/
# Download:  https://downloads.xiph.org/releases/vorbis/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
