#! /bin/bash

PRGNAME="protobuf"

### protobuf (Google's data interchange format)
# Механизм для сериализации структурированных данных Google

# Required:    abseil-cpp
#              cmake
# Recommended: no
# Optional:    gtest        (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# utf8_range нужен для сборки пакета android-tools
#    -D utf8_range_ENABLE_INSTALL=ON
cmake                                 \
    -D CMAKE_INSTALL_PREFIX=/usr      \
    -D CMAKE_BUILD_TYPE=Release       \
    -D CMAKE_SKIP_INSTALL_RPATH=ON    \
    -D protobuf_BUILD_TESTS=OFF       \
    -D protobuf_ABSL_PROVIDER=package \
    -D protobuf_BUILD_LIBUPB=OFF      \
    -D protobuf_BUILD_SHARED_LIBS=ON  \
    -D utf8_range_ENABLE_INSTALL=ON   \
    -G Ninja                          \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Google's data interchange format)
#
# Protocol Buffers are Google's language-neutral, platform-neutral, extensible
# mechanism for serializing structured data.
#
# Home page: https://github.com/google/${PRGNAME}
# Download:  https://github.com/protocolbuffers/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
