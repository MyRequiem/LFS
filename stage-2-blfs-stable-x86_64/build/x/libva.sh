#! /bin/bash

PRGNAME="libva"

### libva (Video Acceleration API)
# Библиотеки VAAPI (Video Acceleration API) для разрешения доступа к
# аппаратному обеспечению для ускорения обработки видео и разгрузки ЦП

# Required:    libdrm
# Recommended: mesa
# Optional:    doxygen
#              wayland
#              intel-gpu-tools

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

# NOTE:
# Если мы переустанавливаем этот пакет, нужно обязательно удалить установленную
# версию пакета
if [ -x /usr/lib/libva.so ]; then
    echo -en "***\n* Before reinstalling the package, you need "
    echo -e "to remove the installed version\n***"
    exit 1
fi

source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

/sbin/ldconfig

# Установка intel-vaapi-driver
# ----------------------------------
# Intel-vaapi-driver разработан специально для видеокарт на базе графического
# процессора Intel

IVAAPIDR="intel-vaapi-driver"
tar -xvf "${SOURCES}/${IVAAPIDR}"-*.tar.bz2 || exit 1
cd ${IVAAPIDR}-* || exit 1

# shellcheck disable=SC2086
./configure        \
    ${XORG_CONFIG} || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
# Home page: http://www.freedesktop.org/wiki/Software/vaapi
# Download:  https://github.com/intel/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
