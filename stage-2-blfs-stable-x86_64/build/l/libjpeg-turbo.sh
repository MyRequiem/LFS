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

# разрешаем сборку с CMake>=4.0
#    -D CMAKE_POLICY_VERSION_MINIMUM=3.5
# заставляет cmake удалять жестко закодированные пути поиска библиотеки (rpath)
# при установке двоичного исполняемого файла или общей библиотеки, но для этого
# пакета не требуется rpath после его установки в стандартное расположение, и
# rpath иногда может вызывать нежелательные эффекты или даже проблемы с
# безопасностью
#    -D CMAKE_SKIP_INSTALL_RPATH=ON
# обеспевает совместимость с libjpeg версии 8
#    -D WITH_JPEG8=ON
cmake                                                              \
    -D CMAKE_INSTALL_PREFIX=/usr                                   \
    -D CMAKE_BUILD_TYPE=RELEASE                                    \
    -D ENABLE_STATIC=FALSE                                         \
    -D CMAKE_INSTALL_DEFAULT_LIBDIR=lib                            \
    -D CMAKE_POLICY_VERSION_MINIMUM=3.5                            \
    -D CMAKE_SKIP_INSTALL_RPATH=ON                                 \
    -D CMAKE_INSTALL_DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" \
    -D WITH_JPEG8=ON                                               \
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
# Home page: https://${PRGNAME}.virtualgl.org
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
