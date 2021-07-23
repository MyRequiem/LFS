#! /bin/bash

PRGNAME="x265"

### x265 (H265/HEVC video encoder)
# Библиотека и утилита для кодирования видеопотоков в формат H.265/MPEG-H HEVC

# Required:    cmake
# Recommended: nasm
# Optional:    numactl (https://github.com/numactl/numactl)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir bld
cd bld || exit 1

cmake                           \
    -DCMAKE_INSTALL_PREFIX=/usr \
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
# Download:  https://github.com/videolan/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
