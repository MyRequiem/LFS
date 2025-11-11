#! /bin/bash

PRGNAME="libei"

### libei (library for Emulated Input)
# Библиотека эмуляции ввода, в первую очередь ориентированная на стек Wayland

# Required:    python3-attrs
#              elogind
# Recommended: no
# Optional:    libevdev
#              libxkbcommon
#              libxml2
#              --- для тестов ---
#              munit                (https://github.com/nemequ/munit)
#              python3-structlog    (https://pypi.org/project/structlog/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup             \
    --prefix=/usr       \
    --buildtype=release \
    -D tests=disabled || exit 1

ninja || exit 1

### тесты
# meson configure -D tests=enabled || exit 1
# ninja test

DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for Emulated Input)
#
# libei is a library for Emulated Input, primarily aimed at the Wayland stack.
# It provides three parts:
#    * EI (Emulated Input) for the client side (libei)
#    * EIS (Emulated Input Server) for the server side (libeis)
#    * oeffis is an optional helper library for DBus communication with the
#       XDG RemoteDesktop portal (liboeffis)
#
# Home page: https://gitlab.freedesktop.org/libinput/${PRGNAME}
# Download:  https://gitlab.freedesktop.org/libinput/${PRGNAME}/-/archive/${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
