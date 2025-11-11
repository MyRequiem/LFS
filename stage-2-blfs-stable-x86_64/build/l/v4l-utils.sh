#! /bin/bash

PRGNAME="v4l-utils"

### v4l-utils (libraries and utilities for video4linux)
# набор утилит для мультимедийных устройств, позволяющих работать с
# проприетарными форматами, доступными для большинства веб-камер (libv4l)

# Required:    no
# Recommended: alsa-lib
#              glu
#              libjpeg-turbo
# Optional:    doxygen
#              qt6              (для сборки qv4l2 и qvidcap)
#              sdl2
#              llvm
#              libbpf           (https://github.com/libbpf/libbpf)
#              sdl_image        (https://github.com/libsdl-org/SDL_image)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

sed -i '/^ir_bpf_enabled/s/=.*/= false/' utils/keytable/meson.build || exit 1

mkdir build
cd build || exit 1

meson setup ..          \
    --prefix=/usr       \
    --buildtype=release \
    -D gconv=disabled   \
    -D doxygen-doc=disabled || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

for PROG in v4l2gl v4l2grab ; do
    cp -v "contrib/test/${PROG}" "${TMP_DIR}/usr/bin"
done

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (libraries and utilities for video4linux)
#
# v4l-utils provides a series of utilities for media devices, allowing the
# ability to handle the proprietary formats available from most webcams
# (libv4l), and providing tools to test V4L devices
#
# Home page: https://www.linuxtv.org
# Download:  https://www.linuxtv.org/downloads/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
