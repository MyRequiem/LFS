#! /bin/bash

PRGNAME="libwebp"

### libwebp (WebP photo compression library)
# WebP - метод сжатия, который обычно используется для фотографий. Степень
# сжатия регулируется, поэтому пользователь может выбрать компромисс между
# размером файла и качеством изображения. WebP обычно достигает в среднем на
# 39% больше сжатия, чем у JPEG и JPEG 2000, без потери качества. Пакет libwebp
# содержит библиотеки и вспомогательные утилиты для кодирования и декодирования
# изображений в этом формате.

# Required:    no
# Recommended: libjpeg-turbo
#              libpng
#              libtiff
#              sdl2
# Optional:    freeglut
#              giflib

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure                 \
    --prefix=/usr           \
    --enable-libwebpmux     \
    --enable-libwebpdemux   \
    --enable-libwebpdecoder \
    --enable-libwebpextras  \
    --enable-swap-16bit-csp \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (WebP photo compression library)
#
# WebP is a method of lossy compression that can be used on photographic
# images. The degree of compression is adjustable so a user can choose the
# trade-off between file size and image quality. WebP typically achieves an
# average of 39% more compression than JPEG and JPEG 2000, without loss of
# image quality. The libwebp package contains a library and support programs to
# encode and decode images in WebP format.
#
# Home page: https://developers.google.com/speed/webp/
# Download:  https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
