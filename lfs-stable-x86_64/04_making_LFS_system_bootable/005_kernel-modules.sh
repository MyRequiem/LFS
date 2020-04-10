#! /bin/bash

PRGNAME="kernel-modules"
VERSION="$1"

### Linux kernel modules
# Модули ядра linux

# http://www.linuxfromscratch.org/lfs/view/stable/chapter08/kernel.html

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

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

cd "${SRC_DIR}" || exit 1

NUMJOBS="$(($(nproc) + 1))"
make -j"${NUMJOBS}" modules || exit 1
make modules_install

# чаще всего модули ядра загружаются автоматически, но так происходит не
# всегда, или модули загружаются в неверном порядке. Программы для загрузки
# модулей (modprobe или insmod) читают конфигурационные файлы из каталога
# /etc/modprobe.d/ Укажем в нем правильный порядок загрузки модулей для USB:
# сначала загружается ehci_hcd, затем ohci_hcd и потом uhci_hcd
install -v -m755 -d /etc/modprobe.d
USB_CONF="/etc/modprobe.d/usb.conf"
if [ -f "${USB_CONF}" ]; then
    mv "${USB_CONF}" "${USB_CONF}.old"
fi

cat << EOF > "${USB_CONF}"
# Begin "${USB_CONF}"

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End "${USB_CONF}"
EOF

config_file_processing "${USB_CONF}"

TARGET="/var/log/packages/${PRGNAME}-${VERSION}"
cat << EOF > "${TARGET}"
# Package: ${PRGNAME} (Linux kernel modules)
#
# Kernel modules are pieces of code that can be loaded and unloaded into the
# kernel upon demand. They extend the functionality of the kernel without the
# need to reboot the system. These modules provide support for hardware such as
# USB devices, RAID controllers, network interfaces, and display devices, or
# add other additional capabilities to the kernel.
#
/etc/modprobe.d
/etc/modprobe.d/usb.conf
EOF

find "/lib/modules/${VERSION}" | sort >> "${TARGET}"
# удалим пустые строки
sed -i '/^$/d' "${TARGET}"
