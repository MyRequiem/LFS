#! /bin/bash

PRGNAME="kernel-generic"
VERSION="$1"

### Linux kernel generic (a general purpose SMP Linux kernel)
# Ядро linux

# LFS рекомендует использовать последнюю стабильную версию ядра.
# Конфигурация ядра для BLFS:
#    http://www.linuxfromscratch.org/blfs/view/stable/longindex.html#kernel-config-index

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

if [ -z "${VERSION}" ]; then
    echo "Usage: $0 <kernel-version>"
    exit 1
fi

SRC_DIR="/usr/src/linux-${VERSION}"
if ! [ -d "${SRC_DIR}" ]; then
    echo "Directory ${SRC_DIR} not found !!!"
    echo "You need to install 'kernel-source-${VERSION}' package"
    exit 1
fi

CONFIG="${ROOT}lfs-kernel-config-${VERSION}"
if ! [ -f "${ROOT}lfs-kernel-config-${VERSION}" ]; then
    echo "Config for linux kernel ${CONFIG} not found !!!"
    exit 1
fi

cd "${SRC_DIR}" || exit 1

# очистим дерево исходников
echo "make mrproper..."
make mrproper

# копируем заранее приготовленный конфиг
cp "${CONFIG}" .config || exit 1

NUMJOBS="$(nproc)"
# собираем ядро
make -j"${NUMJOBS}" bzImage || exit 1

# устанавливаем собранное ядро, System.map и config в /boot
install -vm644 arch/x86/boot/bzImage "/boot/vmlinuz-generic-${VERSION}"
install -vm644 System.map            "/boot/System.map-generic-${VERSION}"
install -vm644 .config               "/boot/config-generic-${VERSION}"

# ссылки в /boot
#    vmlinuz    -> vmlinuz-generic-${VERSION}
#    System.map -> System.map-generic-${VERSION}
#    config     -> config-generic-${VERSION}
ln -svf "vmlinuz-generic-${VERSION}"    /boot/vmlinuz
ln -svf "System.map-generic-${VERSION}" /boot/System.map
ln -svf "config-generic-${VERSION}"     /boot/config

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (a general purpose SMP Linux kernel)
#
# This is a Linux kernel with built-in support for most disk controllers. To
# use filesystems, or to load support for a SCSI or other controller, then
# you'll need to load one or more kernel modules using an initial ramdisk, or
# initrd.
#
# SMP is "Symmetric multiprocessing", or multiple CPU/core support
#
/boot/System.map
/boot/System.map-generic-${VERSION}
/boot/config
/boot/config-generic-${VERSION}
/boot/vmlinuz
/boot/vmlinuz-generic-${VERSION}
EOF
