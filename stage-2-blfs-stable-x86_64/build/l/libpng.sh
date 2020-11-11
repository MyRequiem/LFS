#! /bin/bash

PRGNAME="libpng"

### libpng (Portable Network Graphics library)
# Библиотеки, используемые другими программами для чтения и создания файлов
# PNG. Формат PNG был разработан в качестве замены формата GIF и TIFF, со
# многими улучшениями и расширениями.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

# патч для включения функций анимации png (apng) в libpng (используется в
# Firefox, Seamonkey и Thunderbird):
gzip -cd "${SOURCES}/${PRGNAME}-${VERSION}-apng.patch.gz" | \
    patch -p1 --verbose || exit 1

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# документация
mkdir -pv "${DOCS}"
cp -v README libpng-manual.txt "${TMP_DIR}${DOCS}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Portable Network Graphics library)
#
# PNG (Portable Network Graphics) is an extensible file format for the
# lossless, portable, well-compressed storage of raster images. PNG provides a
# patent-free replacement for GIF and can also replace many common uses of
# TIFF. Indexed-color, grayscale, and truecolor images are supported, plus an
# optional alpha channel. Sample depths range from 1 to 16 bits.
#
# Home page: http://libpng.org/pub/png/${PRGNAME}.html
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
