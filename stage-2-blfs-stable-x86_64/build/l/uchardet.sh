#! /bin/bash

PRGNAME="uchardet"

### Uchardet (encoding detector library)
# библиотека для распознавания кодировок, которая принимает последовательность
# байтов в неизвестной кодировке символов без какой-либо дополнительной
# информации и пытается определить ее кодировку. Возвращаемые имена кодировок
# совместимы с iconv

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

cmake                                   \
    -D CMAKE_INSTALL_PREFIX=/usr        \
    -D BUILD_STATIC=OFF                 \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -W no-dev                           \
    .. || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (encoding detector library)
#
# uchardet uchardet is a C language binding of the original C++ implementation
# of the universal charset detection library by Mozilla. uchardet is an
# encoding detector library, which takes a sequence of bytes in an unknown
# character encoding without any additional information, and attempts to
# determine the encoding of the text. Returned encoding names are
# iconv-compatible
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://www.freedesktop.org/software/${PRGNAME}/releases/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
