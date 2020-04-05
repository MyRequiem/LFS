#! /bin/bash

PRGNAME="linux-kernel-and-modules"
VERSION="5.2.21"

### Linux
# Linux kernel and modules

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter08/kernel.html

# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v5.x/linux-5.2.21.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/

# Версия ядра linux для LFS-9.0 - 5.2.8
# По рекомендации на странице
# http://www.linuxfromscratch.org/lfs/view/9.0/chapter03/packages.html
# cледует использовать последнюю доступную версию ядра 5.2.x
# На 15.03.20 последняя версия ядра ветки 5.2.x это 5.2.21

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

ARCH_NAME="linux"
cd /usr/src || exit 1
rm -rf "${ARCH_NAME}-${VERSION}"

tar xvf "/sources/${ARCH_NAME}-${VERSION}".tar.?z* || exit 1
cd "${ARCH_NAME}-${VERSION}" || exit 1
chown -R root:root ./*

# очистим дерево исходников
make mrproper

# конфигурация ядра для BLFS
# http://www.linuxfromscratch.org/blfs/view/9.0/longindex.html#kernel-config-index
# копируем заранее приготовленный конфиг, который должен лежать в корне
# файловой системы LFS вместе с этим скритом
cp "/lfs-kernel-config-${VERSION}" .config || exit 1

NUMJOBS="$(($(nproc) + 1))"
# собираем ядро
make -j"${NUMJOBS}" bzImage || exit 1
# собираем модули
make -j"${NUMJOBS}" modules || exit 1
# устанавливаем модули
make modules_install
# устанавливаем собранное ядро, System.map и config в /boot
cp -v arch/x86/boot/bzImage "/boot/vmlinuz-lfs-${VERSION}"
cp -v System.map "/boot/System.map-lfs-${VERSION}"
cp -v .config "/boot/config-lfs-${VERSION}"

# устанавливаем документацию для Linux kernel
install -d "/usr/share/doc/${ARCH_NAME}-${VERSION}"
cp -r Documentation/* "/usr/share/doc/${ARCH_NAME}-${VERSION}"

# чаще всего модули ядра загружаются автоматически, но так происходит не
# всегда, или модули загружаются в неверном порядке. Программы для загрузки
# модулей (modprobe или insmod) читают конфигурационные файлы из каталога
# /etc/modprobe.d/ Укажем в нем правильный порядок загрузки модулей для USB:
# сначала загружается ehci_hcd, затем ohci_hcd и потом uhci_hcd
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

# пишем в /var/log/packages/
MAJ_VERSION="$(echo "${VERSION}" | cut -d . -f 1)"
cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Linux kernel and modules)
#
# This is a Linux kernel and modules.
#
# Home page:    https://www.kernel.org/
# Download:     https://www.kernel.org/pub/linux/kernel/v${MAJ_VERSION}.x/${ARCH_NAME}-${VERSION}.tar.xz
# All versions: https://mirrors.edge.kernel.org/pub/linux/kernel/
#
EOF

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{boot,usr/{src,share/doc},lib/modules,etc/modprobe.d}

# исходники
cp -vR "/usr/src/${ARCH_NAME}-${VERSION}" "${TMP_DIR}/usr/src/"

# /boot
cp -v "/boot/vmlinuz-lfs-${VERSION}"    "${TMP_DIR}/boot"
cp -v "/boot/System.map-lfs-${VERSION}" "${TMP_DIR}/boot"
cp -v "/boot/config-lfs-${VERSION}"     "${TMP_DIR}/boot"

# модули
cp -vR "/lib/modules/${VERSION}" "${TMP_DIR}/lib/modules/"

# документация
cp -vR "/usr/share/doc/${ARCH_NAME}-${VERSION}" "${TMP_DIR}/usr/share/doc/"

# /etc/modprobe.d/
cp -v /etc/modprobe.d/usb.conf "${TMP_DIR}/etc/modprobe.d/"

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
