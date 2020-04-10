#! /bin/bash

PRGNAME="kernel-firmware"
ARCH_NAME="linux-firmware"

### Firmware for the linux kernel
# Файлы прошивки для ядра Linux которые используются для аппаратных драйверов.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/firmware.html

# Home page: https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
# Download:  https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/snapshot/linux-firmware-20200316.tar.gz
#            git clone git://git.kernel.org/pub/scm/linux/kernel/git/dwmw2/linux-firmware.git
#            Зеркало LFS: http://anduin.linuxfromscratch.org/BLFS/linux-firmware/

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/{lib/firmware,usr/share/doc}

chown -R root:root ./*

# удалим исходники carl9170fw
if [ -d carl9170fw ]; then
    mv carl9170fw/COPYRIGHT COPYRIGHT.carl9170fw
    mv carl9170fw/GPL LICENSE.carl9170fw
    rm -rf carl9170fw
fi

cp -R ./* /lib/firmware
cp -R ./* "${TMP_DIR}/lib/firmware"

# устанавливаем ссылку на документацию в /usr/share/doc
(
    cd /usr/share/doc || exit 1
    rm -f "${PRGNAME}-${VERSION}"
    ln -sf ../../../lib/firmware/ "${PRGNAME}-${VERSION}"
)

echo "Link to /lib/firmware" > "${TMP_DIR}/usr/share/doc/${PRGNAME}-${VERSION}"

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
