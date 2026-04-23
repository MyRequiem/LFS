#! /bin/bash

PRGNAME="mesa"

### Mesa (OpenGL compatible 3D graphics library)
# Главная коллекция свободных драйверов. Именно она заставляет работать
# 3D-ускорение на картах Intel, AMD и NVIDIA в Linux.

# Required:    xorg-libraries
#              libdrm
#              python3-mako
#              python3-pyyaml
# Recommended: glslang                      (для поддержки vulkan)
#              libva                        (для поддержки gallium drivers) Циклическая зависимость.
#                                               Сначала собираем libva без поддержки egl и glx, т.е. без
#                                               пакета mesa, и после установки mesa пересобираем libva
#              llvm                         (для сборки llvmpipe, r300, r600 и radeonsi драйверов)
#              wayland-protocols            (для сборки KDE Plasma, GNOME, а так же рекомендуется для gtk+3)
#              libclc                       (для intel iris gallium driver)
#              vulkan-loader                (для zink gallium driver)
#              --- для сборки Nouveau Vulkan driver ---
#              cbindgen
#              make-ca
#              rust-bindgen
# Optional:    libdisplay-info
#              libunwind
#              lm-sensors
#              valgrind
#              mesa-demos                   (ftp://ftp.freedesktop.org/pub/mesa/demos/)
#                                               Патч ниже добавляет теже утилиты, что и mesa-demos
#                                               (glxinfo и glxgears), поэтому при его использовании в
#                                               пакете mesa-demos нет необходимости
#              bellagio-openmax             (https://omxil.sourceforge.net/) для мобильных платформ
#              libglvnd                     (https://www.linuxfromscratch.org/glfs/view/dev/shareddeps/libglvnd.html)
#              libtizonia                   (https://github.com/tizonia/tizonia-openmax-il/wiki/Tizonia-OpenMAX-IL/)

###
# WARNING:
#    * Если мы пересобираем пакет, то делать это нужно в ЧИСТОЙ КОНСОЛИ (TTY),
#       иначе после пересборки и установки темный экран и Xorg повиснет.
#    * Для сборки Nouveau Vulkan driver (libvulkan_nouveau.so) требуется сеть
#       Internet, поэтому СОБИРАЕМ ТОЛЬКО В ЧИСТОЙ LFS системе (не в chroot
#       хоста)
###

# Конфигурация ядра
#    DRM_NOUVEAU=y|m    - для nouveau (NVIDIA)
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
#
# Gallium Drivers
#    iris    - современный драйвер для Intel
#    i915    - для старых видеокарт Intel (до 2014 года)
#    nouveau - для NVIDIA
#    zink    - OpenGL поверх Vulkan
#    virgl   - для qemu
GDRV="iris,i915,nouveau,softpipe,zink,virgl"
VDRV="intel,nouveau,swrast,virtio"
LAYERS="device-select,intel-nullhw,overlay"
meson setup ..                   \
    --prefix="${XORG_PREFIX}"    \
    --buildtype=release          \
    -D platforms=x11,wayland     \
    -D gallium-drivers="${GDRV}" \
    -D vulkan-drivers="${VDRV}"  \
    -D gallium-rusticl=true      \
    -D valgrind=disabled         \
    -D video-codecs=all          \
    -D libunwind=disabled        \
    -D vulkan-layers="${LAYERS}" \
    -D llvm=enabled              \
    -D shared-llvm=enabled       \
    -D gles1=disabled            \
    -D gles2=enabled             \
    -D microsoft-clc=disabled    \
    -D build-tests=false || exit 1

# ninja || exit 1
ninja > mesa-errors 2>&1

### тесты
# meson configure \
#     -D build-tests=true || exit 1
# ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
