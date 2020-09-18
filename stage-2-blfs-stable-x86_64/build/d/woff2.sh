#! /bin/bash

PRGNAME="woff2"

### woff2 (Web Open Font Format 2 reference implementation)
# Библиотеки для преобразования шрифтов из формата TTF в формат WOFF 2.0.,
# декомпрессии из WOFF 2.0 в TTF. Формат WOFF 2.0 использует алгоритм сжатия
# Brotli для шрифтов, которые могут быть загружены в правилах CSS @font-face

# http://www.linuxfromscratch.org/blfs/view/stable/general/woff2.html

# Home page: https://github.com/google/woff2/
# Download:  https://github.com/google/woff2/archive/v1.0.2/woff2-1.0.2.tar.gz

# Required: brotli
#           cmake
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir out
cd out || exit 1

cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release  \
    .. || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Web Open Font Format 2 reference implementation)
#
# WOFF2 is a library for converting fonts from the TTF format to the WOFF 2.0
# format. It also allows decompression from WOFF 2.0 to TTF. The WOFF 2.0
# format uses the Brotli compression algorithm to compress fonts suitable for
# downloading in CSS @font-face rules.
#
# Home page: https://github.com/google/${PRGNAME}/
# Download:  https://github.com/google/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
