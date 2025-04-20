#! /bin/bash

PRGNAME="libaom"

### libaom (reference version of the Alliance for Open Media video codec)
# Пакет содержит эталонную версию Alliance for Open Media video codec. Кодек
# является незапатентованной альтернативой H.265 и начинает использоваться в
# Интернете

# Required:    no
# Recommended: yasm или nasm
# Optional:    doxygen

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir aom-build
cd aom-build || exit 1

cmake                            \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D CMAKE_BUILD_TYPE=Release  \
    -D BUILD_SHARED_LIBS=1       \
    -D ENABLE_DOCS=no            \
    -D ENABLE_NASM=yes           \
    -G Ninja \
    .. || exit 1

ninja || exit 1
# ninja runtests
DESTDIR="${TMP_DIR}" ninja install

rm -fv "${TMP_DIR}/usr/lib/libaom.a"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (reference version of the Alliance for Open Media video codec)
#
# The libaom package contains a reference version of the Alliance for Open
# Media video codec. This codec is a patent free alternative to H.265, and is
# starting to be used throughout the internet
#
# Home page: https://aomedia.googlesource.com/aom/
# Download:  https://storage.googleapis.com/aom-releases/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
