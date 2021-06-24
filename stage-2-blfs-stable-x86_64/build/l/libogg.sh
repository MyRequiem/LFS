#! /bin/bash

PRGNAME="libogg"

### libogg (Ogg Bitstream library)
# Библиотека для управления потоками битов ogg и файловой структурой Ogg.
# Используется для создания (кодирования) или воспроизведения (декодирования)
# одного физического битового потока при использовании аудиоформата Ogg Vorbis

# Required:    no
# Recommended: no
# Optional:    no

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
# Package: ${PRGNAME} (Ogg Bitstream library)
#
# Libogg is a library for manipulating ogg bitstreams and Ogg file structure.
# It handles both making ogg bitstreams and getting packets from ogg
# bitstreams. This is useful for creating (encoding) or playing (decoding) a
# single physical bit stream. Its needed to use the Ogg Vorbis audio format.
#
# Home page: https://www.xiph.org/ogg/
# Download:  https://downloads.xiph.org/releases/ogg/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
