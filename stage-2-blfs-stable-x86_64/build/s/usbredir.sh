#! /bin/bash

PRGNAME="usbredir"

### usbredir (usb redirection protocol)
# Протокол для перенаправления USB-трафика с одного USB-устройства на другую
# (виртуальную) машину (не на ту, к которой подключено USB-устройство)

# Required:    libusb
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

mkdir build
cd build || exit 1

meson setup           \
    --prefix=/usr     \
    -D tests=disabled \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (usb redirection protocol)
#
# usbredir is a protocol for redirection USB traffic from a single USB device,
# to a different (virtual) machine then the one to which the USB device is
# attached. This package contains usbredirparser, usbredirhost and
# usbredirserver.
#
# Home page: https://www.spice-space.org
# Download:  https://www.spice-space.org/download/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
