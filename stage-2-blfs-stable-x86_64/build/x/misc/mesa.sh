#! /bin/bash

PRGNAME="mesa"

### Mesa (OpenGL compatible 3D graphics library)
# Библиотека трехмерной графики и API. Используются X для обеспечения как
# программного, так и аппаратного ускорение графики.

# Required:    xorg-libraries
#              libdrm
#              python3-mako
#              python3-pyyaml
# Recommended: glslang                      (для поддержки vulkan)
#              libva                        (для поддержки gallium drivers) Циклическая зависимость.
#                                               Сначала собираем libva без поддержки egl и glx, т.е. без
#                                               пакета mesa, и после установки mesa пересобираем libva
#              libvdpau                     (для сборки vdpau драйвера) Циклическая зависимость.
#                                               Сначала собираем libvdpau без поддержки egl и glx, т.е.
#                                               без пакета mesa, и после установки mesa пересобираем
#                                               libvdpau
#              llvm                         (для сборки llvmpipe, r300, r600 и radeonsi драйверов)
#              wayland-protocols            (для сборки plasma5, gnome, а так же
#                                               рекомендуется для gtk+3)
#              libclc                       (для intel iris gallium driver)
#              vulkan-loader                (для zink gallium driver)
#              python3-ply                  (для Intel vulkan driver)
#              --- для сборки Nouveau Vulkan driver ---
#              cbindgen
#              make-ca
#              rust-bindgen
# Optional:    libgcrypt
#              libunwind
#              lm-sensors
#              nettle
#              valgrind
#              mesa-demos                   (ftp://ftp.freedesktop.org/pub/mesa/demos/)
#                                               Патч ниже добавляет теже утилиты, что и mesa-demos
#                                               (glxinfo и glxgears), поэтому при его использовании в
#                                               пакете mesa-demos нет необходимости
#              bellagio-openmax             (https://omxil.sourceforge.net/) для мобильных платформ
#              libtizonia                   (https://github.com/tizonia/tizonia-openmax-il/wiki/Tizonia-OpenMAX-IL/)

###
# WARNING:
#    * Если мы пересобираем пакет, то делать это нужно в ЧИСТОЙ КОНСОЛИ (без
#       запущенного Xorg), иначе после пересборки и установки темный экран и
#       Xorg виснет
#    * Для сборки Nouveau Vulkan driver (libvulkan_nouveau.so) требуется сеть
#       Internet, поэтому СОБИРАЕМ ТОЛЬКО В ЧИСТОЙ LFS системе
#       (не в chroot хоста)
###

# Конфигурация ядра
#    DRM_NOUVEAU=y|m    - для nouveau (NVidia)
#    DRM_I915=y|m       - для i915, crocus, or iris
#    DRM_VGEM=y|m       - для swrast

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# применим патч для включения сборки утилит 'glxinfo' и 'glxgears' (mesa-demos)
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-add_xdemos-4.patch" || exit 1

mkdir build
cd build || exit 1

# Gallium3D и Vulkan драйверы (см. meson.options в дереве исходников)
#    -D gallium-drivers=...
#    -D vulkan-drivers=...

GDRV="i915,nouveau,softpipe,svga,virgl"
VDRV="intel,intel_hasvk,swrast,virtio,nouveau,gfxstream"
LAYERS="device-select,intel-nullhw,overlay"

meson setup ..                   \
    --prefix="${XORG_PREFIX}"    \
    --buildtype=release          \
    -D platforms=x11,wayland     \
    -D gallium-drivers="${GDRV}" \
    -D vulkan-drivers="${VDRV}"  \
    -D valgrind=disabled         \
    -D video-codecs=all          \
    -D libunwind=disabled        \
    -D vulkan-layers="${LAYERS}" \
    -D llvm=enabled              \
    -D shared-llvm=enabled       \
    -D egl=enabled               \
    -D opengl=true               \
    -D glx=dri                   \
    -D gles1=enabled             \
    -D gles2=enabled             \
    -D legacy-x11=dri2 || exit 1

ninja || exit 1

### тесты
# meson configure \
#     -D build-tests=true || exit 1
#
# sed '/float rsqrtf/,/^}/d' \
#     -i ../src/gallium/drivers/llvmpipe/lp_test_arit.c || exit 1
#
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (OpenGL compatible 3D graphics library)
#
# Mesa is a 3-D graphics library with an API very similar to that of another
# well-known 3-D graphics library :). The Mesa libraries are used by X to
# provide both software and hardware accelerated graphics.
#
# Home page: https://www.mesa3d.org/
# Download:  https://mesa.freedesktop.org/archive/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
