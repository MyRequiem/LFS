#! /bin/bash

PRGNAME="mesa"

### Mesa (OpenGL compatible 3D graphics library)
# Библиотека трехмерной графики и API. Используются X для обеспечения как
# программного, так и аппаратного ускорение графики.

# Required:    xorg-libraries
#              libdrm
#              python3-mako
# Recommended: glslang (для поддержки vulkan)
#              libva (для поддержки gallium drivers) Циклическая зависимость.
#                     Сначала собираем libva без поддержки egl и glx, т.е. без
#                     пакета mesa, и после установки mesa пересобираем libva
#              libvdpau (для сборки vdpau драйвера) Циклическая зависимость.
#                     Сначала собираем libvdpau без поддержки egl и glx, т.е.
#                     без пакета mesa, и после установки mesa пересобираем
#                     libvdpau
#              llvm (для сборки gallium3d, nouveau, r300 и radeonsi драйверов,
#                    а так же для swrast - программный растеризатор)
#              wayland-protocols (для сборки plasma5, gnome, а так же
#                                 рекомендуется для gtk+3)
#              libclc                         (для intel iris gallium driver)
#              vulkan-loader                  (для zink gallium driver)
#              ply                            (для intel vulkan driver)
#              cbindgen и rust-bindgen        (для nouveau vulkan driver)
# Optional:    libgcrypt
#              libunwind
#              lm-sensors
#              nettle
#              valgrind
#              mesa-demos       (ftp://ftp.freedesktop.org/pub/mesa/demos/)
#                                 Патч ниже добавляет теже утилиты, что и mesa-demos
#                                 (glxinfo и glxgears), поэтому при его использовании в
#                                 пакете mesa-demos нет необходимости
#              bellagio-openmax (https://omxil.sourceforge.net/) для мобильных платформ
#              libtizonia       (https://github.com/tizonia/tizonia-openmax-il/wiki/Tizonia-OpenMAX-IL/)
#              libvulkan        (https://www.vulkan.org/)

###
# NOTE:
#    Для сборки пакета нужен интернет, поэтому собираем в "живом" LFS (не в
#    среде chroot на хосте)
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
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-add_xdemos-2.patch" || exit 1

mkdir build
cd build || exit 1

# параметр определяет, какие Gallium3D драйверы следует создавать
#    -D gallium-drivers=...
#
#    * auto         создаются все Gallium3D драйвера
#    * r300         для ATI Radeon 9000 или Radeon X серии
#    * r600         для AMD/ATI Radeon HD 2000-6000 сериий
#    * radeonsi     для AMD Radeon HD 7000 или более новых AMD GPU моделей
#    * nouveau      универсальный драйвер для NVidia Gpus
#    * virgl        для QEMU virtual GPU с поддержкой virglrender
#    * svga         для VMWare virtual GPU
#    * swrast       используется как fallback если GPU не поддерживает другие драйвера
#    * iris         для Intel, поставляемых с процессорами Broadwell или более новыми
#    * crocus       для Intel GMA 3000, серии X3000, 4000 или серии X4000
#    * i915         для Intel GMA 900, 950, 3100 или 3150, поставляемых с наборами микросхем или процессорами Atom D/N 4xx/5xx
GALLIUM_DRV="nouveau,i915,virgl,swrast"

# shellcheck disable=SC2086
meson setup ..                          \
    --prefix=${XORG_PREFIX}             \
    --buildtype=release                 \
    -D platforms=x11                    \
    -D gallium-drivers="${GALLIUM_DRV}" \
    -D vulkan-drivers=""                \
    -D valgrind=disabled                \
    -D libunwind=disabled || exit 1

ninja || exit 1
# meson configure -D build-tests=true && ninja test
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
