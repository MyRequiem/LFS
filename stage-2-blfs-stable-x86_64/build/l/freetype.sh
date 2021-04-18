#! /bin/bash

PRGNAME="freetype"

### FreeType (A free, high-quality, and portable font engine)
# Библиотека (портативный движок рендеринга), которая позволяет приложениям
# рендерить шрифты TrueType, OpenType и Type 1

# Required:    no
# Recommended: harfbuzz
#              libpng
#              which
# Optional:    brotli
#              docwriter (для сборки документации) https://pypi.org/project/docwriter/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# включим проверку таблиц GX/AAT и OpenType
#    # AUX_MODULES += gxvalid --> AUX_MODULES +=
#    # AUX_MODULES += otvalid --> AUX_MODULES +=
sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg || exit 1

# включим субпиксельный рендеринг (раскомментируем определение
#    #define FT_CONFIG_OPTION_SUBPIXEL_RENDERING)
sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h || exit 1

# устанавливать man-страницы для freetype-config
#    --enable-freetype-config
./configure          \
    --prefix=/usr    \
    --disable-static \
    --enable-freetype-config || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A free, high-quality, and portable font engine)
#
# FreeType is a free and portable font rendering engine. It has been developed
# to provide support for a number of font formats, including TrueType, Type 1,
# and OpenType, and is designed to be small, efficient, highly customizable,
# and portable while capable of producing high-quality output.
#
# Home page: http://www.freetype.org
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
