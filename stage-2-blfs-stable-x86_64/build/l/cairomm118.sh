#! /bin/bash

PRGNAME="cairomm118"
ARCH_NAME="cairomm"

### cairomm (C++ wrapper for the cairo graphics library)
# C++ интерфейс для графической библиотеки cairo

# Required:    cairo
#              libsigc++3
# Recommended: boost        (для тестов)
# Optional:    doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}-1.18*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}-${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir bld
cd bld || exit 1

meson setup ..              \
    --prefix=/usr           \
    --buildtype=release     \
    -D build-tests=false    \
    -D boost-shared=true    \
    -D build-examples=false \
    -D build-documentation=false || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (C++ wrapper for the cairo graphics library)
#
# cairomm is a C++ wrapper (C++ interface) for the cairo graphics library. It
# offers all the power of cairo with an interface familiar to C++ developers,
# including use of the Standard Template Library where it makes sense.
#
# Home page: https://www.cairographics.org/${ARCH_NAME}/
# Download:  https://www.cairographics.org/releases/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
