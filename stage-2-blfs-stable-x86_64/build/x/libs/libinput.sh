#! /bin/bash

PRGNAME="libinput"

### libinput (Input device library)
# Библиотека для работы с устройствами ввода в X.Org и Wayland, обеспечивающая
# обнаружение/обработку устройств, обработку событий ввода и т.д.

# Required:    libevdev
#              mtdev
# Recommended: no
# Optional:    gtk+3             (для сборки GUI event viewer)
#              --- для тестов ---
#              valgrind
#              libunwind
#              python3-pyparsing
#              --- для документации ---
#              libwacom
#              python3-sphinx

# Конфигурация ядра
#    CONFIG_INPUT_UINPUT=y|m (для тестов)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/xorg_config.sh"                        || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup                   \
    --prefix="${XORG_PREFIX}" \
    --buildtype=release       \
    -Ddebug-gui=false         \
    -Dtests=false             \
    -Dlibwacom=false          \
    -Dudev-dir=/usr/lib/udev  \
    .. || exit 1

ninja || exit 1

# для запуска тестов конфигурируем пакет без опции '-Dtests=false'
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
