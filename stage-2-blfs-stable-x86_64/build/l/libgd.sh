#! /bin/bash

PRGNAME="libgd"
ARCH_NAME="gd"

### libgd (a graphics library)
# Графическая библиотека, позволяющая быстро рисовать изображения с линиями,
# дугами, текстом, несколькими цветами, вырезать и вставлять из других
# изображений, записывать результат в файлы PNG или JPEG

# Required:    libpng
#              freetype
#              fontconfig
#              libjpeg-turbo
#              libtiff
#              libwebp
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# восстановим макросы, используемые PHP
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-${VERSION}.patch" || exit 1

./bootstrap.sh || exit 1
./configure           \
    --prefix=/usr     \
    --disable-static  \
    --program-prefix= \
    --program-suffix= || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a graphics library)
#
# gd is a graphics library. It allows your code to quickly draw images complete
# with lines, arcs, text, multiple colors, cut and paste from other images, and
# flood fills, and write out the result as a PNG or JPEG file. This is
# particularly useful in web applications, where PNG and JPEG are two of the
# formats accepted for inline images by most browsers.
#
# Home page: https://www.${PRGNAME}.org
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/archive/refs/tags/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
