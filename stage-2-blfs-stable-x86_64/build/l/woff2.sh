#! /bin/bash

PRGNAME="woff2"

### WOFF2 (WOFF File Format 2.0 library)
# Библиотека WOFF2 для конвертации шрифтов из формата TTF в формат WOFF 2.0
# Также позволяет распаковывать файлы из WOFF 2.0 в TTF. Формат использует
# алгоритм сжатия Бротли для шрифтов, подходящих для загрузки по правилам CSS
# @font-face

# Required:    brotli
#              cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим проблему сборки с gcc-15
sed -i '/output.h/i #include <cstdint>' src/woff2_out.cc || exit 1

mkdir out
cd out || exit 1

cmake                                   \
    -D CMAKE_INSTALL_PREFIX=/usr        \
    -D CMAKE_BUILD_TYPE=Release         \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -D CMAKE_SKIP_INSTALL_RPATH=ON      \
    .. || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share/doc"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (WOFF File Format 2.0 library)
#
# WOFF2 is a library for converting fonts from the TTF format to the WOFF 2.0
# format. It also allows decompression from WOFF 2.0 to TTF. The WOFF 2.0
# format uses the Brotli compression algorithm to compress fonts suitable for
# downloading in CSS @font-face rules
#
# Home page: https://github.com/google/${PRGNAME}/
# Download:  https://github.com/google/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
