#! /bin/bash

PRGNAME="libdrm"

### libdrm (A library to support Direct Rendering)
# Библиотека реализует интерфейс для служб DRM (Direct Rendering) ядра, прямой
# рендеринг manager в операционных системах, поддерживающих интерфейс ioctl.
# Используется для поддержки аппаратного ускорения 3D рендеринга.

# Required:    no
# Recommended: xorg-libraries (для intel kms api support, требуемой для mesa)
# Optional:    cairo          (для тестов)
#              cmake          (может использоваться для поиска зависимостей без файлов pkgconfig)
#              docbook-xml
#              docbook-xsl
#              libxslt        (для сборки man-страниц)
#              libatomic-ops
#              valgrind
#              cunit          (для amdgpu тестов) http://cunit.sourceforge.net/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

# включаем поддержку Udev вместо mknod
#    -Dudev=true
#
# shellcheck disable=SC2086
meson           \
    -Dudev=true \
    --prefix=${XORG_PREFIX} || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (A library to support Direct Rendering)
#
# This library implements an interface to the kernel's DRM services. It is used
# to support hardware accelerated 3-D rendering and libdrm provides a user
# space library for accessing the DRM, direct rendering manager, on operating
# systems that support the ioctl interface. libdrm is a low-level library,
# typically used by graphics drivers such as the Mesa DRI drivers, the X
# drivers, libva and similar projects.
#
# Home page: https://dri.freedesktop.org/wiki/DRM/
# Download:  https://dri.freedesktop.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
