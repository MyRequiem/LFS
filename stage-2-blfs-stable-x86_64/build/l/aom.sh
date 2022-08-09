#! /bin/bash

PRGNAME="aom"

### aom (Open Source Video Codec)
# Видеокодек AOMedia Video 1 (AV1) разработан как преемник VP9, а также
# является прямым конкурентом HEVC/H.265

# Required:    cmake
#              nasm
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd build || exit 1

cmake                                  \
    -G "Unix Makefiles"                \
    -DCMAKE_INSTALL_PREFIX=/usr        \
    -DCMAKE_INSTALL_INCLUDEDIR=include \
    -DCMAKE_BUILD_TYPE=Release         \
    -DBUILD_SHARED_LIBS=1              \
    -DENABLE_TESTS=0                   \
    -DENABLE_NASM=1                    \
    -DENABLE_DOCS=0                    \
    ..

# собираем в один поток, иначе ошибка
make -j1 || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Open Source Video Codec)
#
# AOMedia Video 1 (AV1) is designed to be the successor to VP9 and also to
# eventually be a direct competitor for HEVC/H.265
#
# Home page: https://aomedia.googlesource.com/${PRGNAME}
# Download:  https://github.com/MyRequiem/LFS/raw/master/stage-2-blfs-stable-x86_64/src/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#            http://www.andrews-corner.org/downloads/
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
