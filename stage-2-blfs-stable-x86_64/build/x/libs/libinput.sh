#! /bin/bash

PRGNAME="libinput"

### libinput (Input device library)
# Универсальный современный драйвер, который управляет всеми устройствами ввода
# в системе. Он отвечает за плавность движений мыши, распознавание сложных
# жестов на тачпаде и предотвращение случайных нажатий ладонью.

# Required:    libevdev
#              mtdev
# Recommended: no
# Optional:    valgrind
#              gtk+3                      (для сборки GUI event viewer)
#              libunwind
#              libwacom
#              doxygen
#              graphviz
#              lua
#              python3-recommonmark
#              python3-sphinx-rtd-theme
#              python3-pyparsing
#              python3-pytest
#              check                      (https://libcheck.github.io/check/)

### Конфигурация ядра
#    CONFIG_INPUT=y
#    --- для тестов ---
#    CONFIG_INPUT_MISC=y
#    CONFIG_INPUT_UINPUT=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup ..                \
    --prefix="${XORG_PREFIX}" \
    --buildtype=release       \
    -D debug-gui=false        \
    -D tests=false            \
    -D libwacom=false         \
    -D udev-dir=/usr/lib/udev || exit 1

ninja || exit 1
# meson configure -D tests=true && ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Input device library)
#
# libinput is a library to handle input devices in Wayland compositors and to
# provide a generic X.Org input driver. libinput provides device detection,
# device handling, input device event processing and abstraction to minimize
# the amount of custom input code compositors need to provide the common set of
# functionality that users expect.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://gitlab.freedesktop.org/${PRGNAME}/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
