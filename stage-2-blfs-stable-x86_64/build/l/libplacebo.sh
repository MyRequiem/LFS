#! /bin/bash

PRGNAME="libplacebo"

### libplacebo (GPU-accelerated video/image rendering primitives library)
# Основные алгоритмы рендеринга и идеи mpv, которые превратились в библиотеку

# Required:    python3
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev | cut -d v -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-v${VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-v${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson                 \
    --prefix=/usr     \
    -Db_ndebug=true   \
    -Dbuildtype=plain \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (GPU-accelerated video/image rendering primitives library)
#
# libplacebo is essentially the core rendering algorithms and ideas of mpv
# turned into a library.
#
# Home page: https://code.videolan.org/videolan/${PRGNAME}
# Download:  https://code.videolan.org/videolan/${PRGNAME}/-/archive/v${VERSION}/${PRGNAME}-v${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
