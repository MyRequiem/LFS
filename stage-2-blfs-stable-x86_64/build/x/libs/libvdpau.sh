#! /bin/bash

PRGNAME="libvdpau"

### libvdpau (VDPAU wrapper library)
# VDPAU - Video Decode and Presentation API for Unix. Библиотека и API,
# изначально разработанные Nvidia для серии GeForce >= 8 и ориентированные на X
# Window System. Это API позволяет видео программам разгрузжать процесс
# декодирования и постобработки видео средствами GPU.

# Required:    xorg-libraries
# Recommended: no
# Optional:    mesa (циклическая зависимость: сначала собираем libvdpau без
#                    поддержки egl и glx, т.е. без пакета mesa, и после
#                    установки mesa пересобираем libvdpau)
#              doxygen
#              graphviz
#              texlive или install-tl-unx

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/profile.d"

DOCS="false"

mkdir build
cd build || exit 1

# shellcheck disable=SC2086
meson                       \
    --prefix=${XORG_PREFIX} \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

[[ "x${DOCS}" == "xfalse" ]] && rm -rf "${TMP_DIR}/usr/share/doc"

VDPAU_SH="/etc/profile.d/vdpau.sh"
cat << EOF > "${TMP_DIR}${VDPAU_SH}"
#!/bin/sh

# disable debugging output of the vdpau backend
export VDPAU_LOG=0

### use the vdpau backend:
# export VDPAU_DRIVER="nvidia"
export VDPAU_DRIVER="nouveau"
# export VDPAU_DRIVER="r300"
# export VDPAU_DRIVER="r600"
# export VDPAU_DRIVER="radeonsi"
# export VDPAU_DRIVER="va_gl"
EOF

chmod 755 "${TMP_DIR}${VDPAU_SH}"

if [ -f "${VDPAU_SH}" ]; then
    mv "${VDPAU_SH}" "${VDPAU_SH}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${VDPAU_SH}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (VDPAU wrapper library)
#
# VDPAU (Video Decode and Presentation API for Unix) is an open source library
# (libvdpau) and API originally designed by Nvidia for its GeForce 8 series and
# later GPU hardware targeted at the X Window System This VDPAU API allows
# video programs to offload portions of the video decoding process and video
# post-processing to the GPU video-hardware.
#
# Home page: http://cgit.freedesktop.org/~aplattner/${PRGNAME}
# Download:  https://gitlab.freedesktop.org/vdpau/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
