#! /bin/bash

PRGNAME="usbutils"

### usbutils (USB utilities)
# Утилиты, используемые для отображения информации о шинах USB в системе и
# подключенных к ним устройствах

# Required:    libusb
# Recommended: hwdata    (runtime)
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure        \
    --prefix=/usr  \
    --datadir=/usr/share/hwdata || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (USB utilities)
#
# The USB Utils package contains utilities used to display information about
# USB buses in the system and the devices connected to them.
#
# Home page: https://github.com/gregkh/${PRGNAME}
# Download:  https://kernel.org/pub/linux/utils/usb/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
