#! /bin/bash

PRGNAME="kernel-firmware"
ARCH_NAME="linux-firmware"

### Firmware for the linux kernel
# Файлы прошивки для ядра Linux которые используются для аппаратных драйверов.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/lib/firmware"

# удалим исходники carl9170fw
if [ -d carl9170fw ]; then
    mv carl9170fw/COPYRIGHT COPYRIGHT.carl9170fw
    mv carl9170fw/GPL LICENSE.carl9170fw
    rm -rf carl9170fw
fi

cp -vpR ./* /usr/lib/firmware/
cp -vpR ./* "${TMP_DIR}/usr/lib/firmware/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Firmware for the kernel)
#
# These are firmware files for the Linux kernel. You'll need these to use
# certain hardware drivers with Linux.
#
# Home page: https://git.kernel.org/pub/scm/linux/kernel/git/firmware/${ARCH_NAME}.git
# Download:  https://git.kernel.org/pub/scm/linux/kernel/git/firmware/${ARCH_NAME}.git/snapshot/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
