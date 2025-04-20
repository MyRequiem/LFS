#! /bin/bash

PRGNAME="libplacebo"

### libplacebo (GPU-accelerated video/image rendering primitives library)
# Основные алгоритмы рендеринга и идеи mpv, которые превратились в библиотеку

# Required:    ffmpeg
#              python3-glad
# Recommended: glslang
#              vulkan-loader
# Optional:    lcms2
#              libunwind
#              dovi_tool        (https://github.com/quietvoid/dovi_tool/)
#              nuklear          (https://github.com/Immediate-Mode-UI/Nuklear)
#              xxhash           (https://github.com/Cyan4973/xxHash)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D tests=false      \
    -D demos=false || exit 1

ninja || exit 1
# ninja test
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
# Download:  https://github.com/haasn/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
