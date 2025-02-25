#! /bin/bash

PRGNAME="maim"

### maim (make image)
# Утилита для создания скриншотов

# Required:    imlib2
#              slop
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# ошибка сборки с новыми версиями icu, поэтому отключим поддержку ICU, удалив
# диапозон строк 70-81 в CMakeLists.txt
sed '70,81 d;' -i CMakeLists.txt

cmake \
    -D CMAKE_INSTALL_PREFIX=/usr

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (make image)
#
# maim (make image) is an utility that takes a screenshot of your desktop, and
# encodes a png, jpg, bmp or webp image of it. By default it outputs the
# encoded image data directly to standard output. It's meant to overcome
# shortcomings of scrot and performs better in several ways.
#
# Home page: https://github.com/naelstrof/${PRGNAME}
# Download:  https://github.com/naelstrof/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
