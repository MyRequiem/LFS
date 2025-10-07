#! /bin/bash

PRGNAME="x265"

### x265 (H265/HEVC video encoder)
# Библиотека и утилита для кодирования видеопотоков в формат H.265/MPEG-H HEVC

# Required:    cmake
# Recommended: nasm
# Optional:    numactl (https://github.com/numactl/numactl)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}_*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d _ -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}_${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}_${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# удалим некоторые настройки политики CMake, которые больше не совместимы с
# CMake-4.0
sed -r '/cmake_policy.*(0025|0054)/d' -i source/CMakeLists.txt

mkdir bld
cd bld || exit 1

cmake -D CMAKE_INSTALL_PREFIX=/usr        \
      -D GIT_ARCHETYPE=1                  \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -W no-dev                           \
      ../source || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# не используем статическую библиотеку
rm -vf "${TMP_DIR}/usr/lib/lib${PRGNAME}.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (H265/HEVC video encoder)
#
# x265 is free software library and application for encoding video streams into
# the H.265/MPEG-H HEVC compression format.
#
# Home page: https://www.videolan.org/developers/${PRGNAME}.html
# Download:  https://bitbucket.org/multicoreware/${PRGNAME}_git/downloads/${PRGNAME}_${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
