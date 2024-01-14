#! /bin/bash

PRGNAME="mesa"

### Mesa (OpenGL compatible 3D graphics library)
# Библиотека трехмерной графики и API. Используются X для обеспечения как
# программного, так и аппаратного ускорение графики.

# Required:    xorg-libraries
#              libdrm
#              python3-mako
# Recommended: libva (для поддержки gallium drivers) Циклическая зависимость.
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
#              glslang          (https://github.com/KhronosGroup/glslang) для драйвера vulkan
#              libtizonia       (https://github.com/tizonia/tizonia-openmax-il/wiki/Tizonia-OpenMAX-IL/)
#              libvulkan        (https://www.vulkan.org/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# применим патч для включения сборки утилит 'glxinfo' и 'glxgears' (mesa-demos)
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-add_xdemos-1.patch" || exit 1

mkdir build
cd build || exit 1

if [ -d /usr/share/wayland-protocols ]; then
    PLATFORMS="x11,wayland"
else
    PLATFORMS="x11"
fi

VALGRIND="disabled"
LIBUNWIND="disabled"
# command -v valgrind &>/dev/null && VALGRIND="enabled"
[ -x /usr/lib/libunwind.so ] && LIBUNWIND="enabled"

# shellcheck disable=SC2086
meson                                  \
    --prefix=${XORG_PREFIX}            \
    --buildtype=release                \
    -Dplatforms="${PLATFORMS}"         \
    -Dgallium-drivers=auto             \
    -Dvulkan-drivers=""                \
    -Dvalgrind="${VALGRIND}"           \
    -Dlibunwind="${LIBUNWIND}"         \
    -Dbuild-tests=false                \
    .. || exit 1

ninja || exit 1

### тесты
# для запуска тестов необходимо конфигурировать mesa с параметром
#    -Dbuild-tests=true
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
