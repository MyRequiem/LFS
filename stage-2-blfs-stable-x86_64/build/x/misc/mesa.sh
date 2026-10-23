#! /bin/bash

PRGNAME="mesa"

### Mesa (OpenGL compatible 3D graphics library)
# Главная коллекция свободных драйверов. Именно она заставляет работать
# 3D-ускорение на картах Intel, AMD и NVIDIA в Linux.

# Required:    xorg-libraries
#              libdrm
#              python3-mako
#              python3-pyyaml
#              spirv-llvm-translator
#              llvm                         (для сборки llvmpipe, r300, r600 и radeonsi драйверов)
#              libclc
#              libva                        (для поддержки gallium drivers) Циклическая зависимость.
#                                               Сначала собираем libva без поддержки egl и glx, т.е. без
#                                               пакета mesa, и после установки mesa пересобираем libva
# Recommended: glslang                      (для поддержки Vulkan)
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
#              libglvnd                     (https://www.linuxfromscratch.org/glfs/view/dev/shareddeps/libglvnd.html)
#              opencl-icd-loader            (https://github.com/KhronosGroup/OpenCL-ICD-Loader)

###
# WARNING:
#    * Если мы пересобираем пакет, то делать это нужно в ЧИСТОЙ КОНСОЛИ (TTY),
#      иначе после пересборки и установки темный экран и Xorg повиснет.
#    * Для сборки Nouveau Vulkan driver (libvulkan_nouveau.so) требуется сеть
#      Internet, поэтому СОБИРАЕМ ТОЛЬКО В ЧИСТОЙ LFS системе (не в chroot
#      хоста).
###

# Конфигурация ядра.
#    DRM_NOUVEAU=y|m    - для nouveau (NVIDIA)
#    DRM_I915=y|m       - для i915, crocus, or iris
#    DRM_VGEM=y|m       - для swrast

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Применим патч для включения сборки утилит glxinfo и glxgears (mesa-demos).
patch --verbose -Np1 -i "${SOURCES}/${PRGNAME}-add_xdemos-5.patch" || exit 1

mkdir build
cd build || exit 1

# ==============================================================================
# Опции gallium-drivers и vulkan-drivers определяют список собираемых
# графических драйверов Mesa.
#
# ДРАЙВЕРА (в зависимости от вашей видеокарты):
# 1. AMD (современные карты и процессоры Ryzen):
#      - gallium: radeonsi (OpenGL)
#      - vulkan:  amd (драйвер RADV)
# 2. Intel (современные встроенные Iris/Xe и дискретные Arc):
#      - gallium: iris (OpenGL)
#      - vulkan:  intel (драйвер ANV)
# 3. Старые Intel (до 2014 года)
#      - gallium: i915,crocus
#      - vulkan:  intel
# 4. Nvidia (открытый графический стек):
#      - gallium: nouveau (OpenGL)
#      - vulkan:  nouveau (Vulkan)
# 5. Программный рендеринг: эмуляторы видеокарты средствами CPU.
#    Используются как аварийный режим если GPU не заводится (например, если
#    слетел драйвер или нужный драйвер отсутствует):
#      - gallium:  llvmpipe - высокопроизводительный многопоточный рендерер с
#                             JIT через LLVM для современных процессоров.
#                  softpipe - эталонный медленный однопоточный рендерер на
#                             чистом C для старых процессоров.
#      - vulkan:   swrast   - программная эмуляция Vulkan на процессоре
#                             (драйвер lavapipe)
#
#      * Рекомендуется всегда собирать llvmpipe/softpipe и swrast для
#        корректного fallback.
#
# ПРИМЕЧАНИЕ ПО OPENCL:
#   Опция gallium-rusticl=false полностью отключают старый и новый движки
#   OpenCL внутри Mesa. Это избавляет систему от проблемного и тяжелого пакета
#   libclc, сохраняя 3D-графику и Vulkan в идеальном состоянии.
# ==============================================================================

GDRV="i915,crocus,softpipe"
VDRV="intel,swrast"
meson setup ..                   \
    --prefix="${XORG_PREFIX}"    \
    --buildtype=release          \
    -D platforms=x11             \
    -D gallium-drivers="${GDRV}" \
    -D vulkan-drivers="${VDRV}"  \
    -D valgrind=disabled         \
    -D video-codecs=all          \
    -D libunwind=disabled        \
    -D gallium-rusticl=false     \
    -D llvm=enabled              \
    -D shared-llvm=enabled       \
    -D gles1=disabled            \
    -D gles2=enabled             \
    -D microsoft-clc=disabled || exit 1

ninja || exit 1
# С выводом ошибок сборки в файл:
# ninja > mesa-ERRORS 2>&1 || exit 1

### Тесты.
# meson configure \
#     -D build-tests=true || exit 1
# ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

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
# Download:  https://${PRGNAME}.freedesktop.org/archive/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
