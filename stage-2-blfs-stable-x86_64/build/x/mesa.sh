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
#              lm-sensors
#              nettle
#              valgrind
#              mesa-demos (ftp://ftp.freedesktop.org/pub/mesa/demos/)
#                         Патч ниже добавляет теже утилиты, что и mesa-demos
#                         (glxinfo и glxgears), поэтому при его использовании в
#                         пакете mesa-demos нет необходимости
#              bellagio-openmax (http://omxil.sourceforge.net/) для мобильных платформ
#              libunwind        (http://www.nongnu.org/libunwind/)
#              libtizonia       (https://github.com/tizonia/tizonia-openmax-il/wiki/Tizonia-OpenMAX-IL)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
DOCS="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}${DOCS}"

# применим патч для включения сборки утилит 'glxinfo' и 'glxgears' (mesa-demos)
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-add_xdemos-1.patch" || exit 1

# настроим набор тестов для использования Python-3, вместо Python-2
sed '1s/python/&3/' -i bin/symbols-check.py || exit 1

mkdir build
cd build || exit 1

# полностью оптимизируем сборку
#    -Dbuildtype=release
# обеспечим поддержку игр MS Windows, требующие DirectX 9
#    -Dgallium-nine=true
# создавать библиотеку libOSMesa и обеспечивать поддержку Gallium3D в ней
# (требуется gallium swrast)
#    -Dosmesa=gallium
# отключаем использование Valgrind во время сборки
#    -Dvalgrind=false
# отключаем сборку кода для тестов
#    -Dbuild-tests=false
GALLIUM_DRV="i915,iris,nouveau,r300,r600,radeonsi,svga,swrast,virgl"
DRI_DRIVERS="i965,nouveau"
PLATFORMS="drm,x11"

# shellcheck disable=SC2086
meson                                  \
    --prefix=${XORG_PREFIX}            \
    -Dbuildtype=release                \
    -Ddri-drivers="${DRI_DRIVERS}"     \
    -Dgallium-drivers="${GALLIUM_DRV}" \
    -Dgallium-nine=true                \
    -Dglx=dri                          \
    -Dosmesa=gallium                   \
    -Dvalgrind=false                   \
    -Dlibunwind=false                  \
    -Dplatforms="${PLATFORMS}"         \
    -Dbuild-tests=false                \
    .. || exit 1

unset GALLIUM_DRV DRI_DRIVERS
ninja || exit 1

### тесты
# для запуска тестов необходимо конфигурировать mesa с параметром
#    -Dbuild-tests=true
#
# известно, что четыре теста из набора glcpp и два теста из набора llvmpipe
# завершаются как fail
# ninja test

DESTDIR="${TMP_DIR}" ninja install

# документация
(
    cd ../docs || exit 1
    mkdir -p html
    mv relnotes html
    rm -rf specs
    mv ./{*.html,*.css,*.ico,*.png} html/
    cp -rfv ./* "${TMP_DIR}${DOCS}"
)

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
