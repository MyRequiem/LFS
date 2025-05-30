#! /bin/bash

PRGNAME="utfcpp"

### utfcpp (UTF-8 in C++)
# Набор заголовочных файлов для предоставления UTF-8 в C++

# Required:    cmake
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

cmake -D CMAKE_INSTALL_PREFIX=/usr .. || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (UTF-8 in C++)
#
# The utfcpp package contains a set of include files to provide UTF-8 with C++
# in a Portable Way
#
# Home page: https://github.com/nemtrif/${PRGNAME}
# Download:  https://github.com/nemtrif/${PRGNAME}/archive/v${VERSION}/${PRGNAME-}${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
