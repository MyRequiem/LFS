#! /bin/bash

PRGNAME="libqrencode"

### libqrencode (encoding data in a QR Code symbol)
# Быстрая и компактная библиотека для кодирования данных в QR-код

# Required:    no
# Recommended: libpng
# Optional:    doxygen    (документация)
#              sdl2       (тесты)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

sh autogen.sh || exit 1
./configure \
    --prefix=/usr || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

# тесты нужно запускать после установки пакета в систему при конфигурации с
# параметром --with-tests
# make check

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (encoding data in a QR Code symbol)
#
# The libqrencode package provides a fast and compact library for encoding data
# in a QR Code symbol, a 2D symbology that can be scanned by handheld terminals
# such as a mobile phone with a CCD sensor
#
# Home page: https://github.com/fukuchi/${PRGNAME}/
# Download:  https://github.com/fukuchi/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
