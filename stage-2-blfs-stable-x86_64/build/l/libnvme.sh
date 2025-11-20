#! /bin/bash

PRGNAME="libnvme"

### libnvme (type definitions for NVMe)
# Библиотека для работы с NVMe (Non-Volatile Memory Express -
# высокопроизводительный протокол передачи данных)

# Required:    no
# Recommended: no
# Optional:    dbus
#              json-c
#              keyutils
#              swig

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
    -D libdbus=auto     \
    .. || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (type definitions for NVMe)
#
# The libnvme package is a library which provides type definitions for NVMe
# specification structures, enumerations, and bit fields, helper functions to
# construct, dispatch, and decode commands and payloads, and utilities to
# connect, scan, and manage NVMe devices on a Linux system.
#
# Home page: https://github.com/linux-nvme/${PRGNAME}/
# Download:  https://github.com/linux-nvme/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
