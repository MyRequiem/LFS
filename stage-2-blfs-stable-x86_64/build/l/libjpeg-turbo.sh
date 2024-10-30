#! /bin/bash

PRGNAME="libjpeg-turbo"

### libjpeg-turbo (high-speed version of libjpeg)
# Форк оригинального libjpeg, который использует SIMD для ускоренного сжатия и
# распаковки JPEG. Библиотека реализует кодирование, декодирование и
# транскодирование изображений JPEG

# Required:    cmake
# Recommended: nasm или yasm (для оптимизации сборки)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -pv build
cd build || exit 1

# обеспевает совместимость с libjpeg версии 8
#    -DWITH_JPEG8=ON
cmake                                                             \
    -DCMAKE_INSTALL_PREFIX=/usr                                   \
    -DCMAKE_BUILD_TYPE=RELEASE                                    \
    -DENABLE_STATIC=FALSE                                         \
    -DWITH_JPEG8=ON                                               \
    -DCMAKE_INSTALL_DEFAULT_LIBDIR=lib                            \
    -DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    .. || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (high-speed version of libjpeg)
#
# libjpeg-turbo is a high-speed version of libjpeg for x86 and x86-64
# processors which uses SIMD instructions (MMX, SSE2, etc.) to accelerate
# baseline JPEG compression and decompression. libjpeg-turbo is generally 2-4x
# as fast as the unmodified version of libjpeg, all else being equal.
#
# Home page: http://${PRGNAME}.virtualgl.org
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
