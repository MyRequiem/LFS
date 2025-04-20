#! /bin/bash

PRGNAME="libva"

### libva (Video Acceleration API)
# Библиотеки VAAPI (Video Acceleration API) для разрешения доступа к
# аппаратному обеспечению для ускорения обработки видео и разгрузки ЦП

# Required:    libdrm
# Recommended: mesa (циклическая зависимость: сначала собираем libva без
#                    поддержки egl и glx, т.е. без пакета mesa, и после
#                    установки mesa пересобираем libva)
#              --- runtime ---
#              intel-vaapi-driver
#              intel-media
# Optional:    doxygen
#              wayland
#              intel-gpu-tools    (https://gitlab.freedesktop.org/drm/igt-gpu-tools)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

cd build || exit 1

# shellcheck disable=SC2086
meson setup                 \
    --prefix=${XORG_PREFIX} \
    --buildtype=release || exit 1

ninja || exit 1
# пакет не имеет набора тестов
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

/usr/sbin/ldconfig

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Video Acceleration API)
#
# The main motivation for VAAPI (Video Acceleration API) is to enabl eaccess to
# hardware accelerated video processing, using hardware to accelerate video
# processing in order to offload the central processing unit (CPU) to decode
# and encode compressed digital video. The VA API video decode/encode interface
# is platform and window system independent targeted at Direct Rendering
# Infrastructure (DRI) in the X Window System however it can potentially also
# be used with direct framebuffer and graphics sub-systems for video output.
# Accelerated processing includes support for video decoding, video encoding,
# subpicture blending, and rendering.
#
# Home page: https://www.freedesktop.org/wiki/Software/vaapi
# Download:  https://github.com/intel/${PRGNAME}/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
