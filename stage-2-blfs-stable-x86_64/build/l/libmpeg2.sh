#! /bin/bash

PRGNAME="libmpeg2"

### libmpeg2 (mpeg-video decoding library)
# Библиотека для декодирования видео MPEG-2 и MPEG-1 потоков

# Required:    no
# Recommended: no
# Optional:    Graphical Environments
#              sdl12-compat

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# устраним проблему сборки с gcc>=15.0
sed -i 's/static const/static/' "${PRGNAME}/idct_mmx.c" || exit 1

./configure         \
    --prefix=/usr   \
    --enable-shared \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (mpeg-video decoding library)
#
# The libmpeg2 package contains a library for decoding MPEG-2 and MPEG-1 video
# streams. The library is able to decode all MPEG streams that conform to
# certain restrictions: ?constrained parameters? for MPEG-1, and ?main profile?
# for MPEG-2. This is useful for programs and applications needing to decode
# MPEG-2 and MPEG-1 video streams.
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  https://download.videolan.org/contrib/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
