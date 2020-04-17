#! /bin/bash

PRGNAME="libjpeg-turbo"

### libjpeg-turbo (high-speed version of libjpeg)
# Форк оригинального libjpeg, который использует SIMD для ускоренного сжатия и
# распаковки JPEG. Библиотека реализует кодирование, декодирование и
# транскодирование изображений JPEG

# http://www.linuxfromscratch.org/blfs/view/stable/general/libjpeg.html

# Home page: http://libjpeg-turbo.virtualgl.org
# Download:  https://downloads.sourceforge.net/libjpeg-turbo/libjpeg-turbo-2.0.4.tar.gz

# Required: cmake
#           nasm или yasm
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir -pv build
cd build || exit 1

cmake                                                             \
    -DCMAKE_INSTALL_PREFIX=/usr                                   \
    -DCMAKE_BUILD_TYPE=RELEASE                                    \
    -DENABLE_STATIC=FALSE                                         \
    -DCMAKE_INSTALL_DEFAULT_LIBDIR=lib                            \
    -DCMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    .. || exit 1

make || exit 1

# make test

# при обновлении пакета не все ссылки на библиотеки в /usr/lib правильно
# обновляются. Исправим это недоразумение:)
rm -f /usr/lib/libjpeg.so*

make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (high-speed version of libjpeg)
#
# libjpeg-turbo is a high-speed version of libjpeg for x86 and x86-64
# processors which uses SIMD instructions (MMX, SSE2, etc.) to accelerate
# baseline JPEG compression and decompression. libjpeg-turbo is generally 2-4x
# as fast as the unmodified version of libjpeg, all else being equal.
#
# Home page: http://libjpeg-turbo.virtualgl.org
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
