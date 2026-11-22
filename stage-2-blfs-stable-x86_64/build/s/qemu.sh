#! /bin/bash

PRGNAME="qemu"

### qemu (open source processor emulator)
# Мощнейший профессиональный эмулятор, способный запускать любые операционные
# системы и имитировать работу различного компьютерного железа. Он является
# основой для создания современных виртуальных машин.

# Required:    glib
#              pixman
# Recommended: alsa-lib
#              dtc              (если не установлен, будет скачан с Internet)
#              libslirp
#              sdl2-compat
# Optional:    pulseaudio
#              curl
#              cyrus-sasl
#              fuse3
#              gnutls
#              gtk+3
#              libaio
#              libusb
#              libgcrypt
#              libjpeg-turbo
#              libseccomp
#              libssh2
#              libpng
#              libtasn1
#              linux-pam
#              lzo
#              nettle
#              mesa
#              vte3
#              libcap-ng
#              spice
#              usbredir
#              elogind          (runtime)

### Конфигурация ядра.
#    CONFIG_VIRTUALIZATION=y
#    CONFIG_KVM=y|m
#    CONFIG_KVM_INTEL=y|m       (для процессоров Intel)
#    или
#    CONFIG_KVM_AMD=y|m         (для процессоров AMD)
#    CONFIG_NET=y
#    CONFIG_BRIDGE=y|m
#    CONFIG_NETDEVICES=y
#    CONFIG_NET_CORE=y
#    CONFIG_TUN=y|m

###
# NOTE:
#    После установки пакета нужно добавить обычного пользователя в группу kvm,
#    т.к. правило udev позволяет использовать устройство KVM только
#    пользователю root:
#       $ usermod -a -G kvm <username>
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/{usr/lib/udev/rules.d,etc/qemu}

# Добавим группу kvm, если не существует.
! grep -qE "^kvm:" /etc/group  && \
    groupadd -g 61 kvm

mkdir -vp build
cd build || exit 1

# x86_64-softmmu отвечает за всю системную виртуализацию (запуск Windows,
# Linux, BSD через KVM/QEMU, работу со SPICE, проброс устройств и т. д.).
TARGETS="x86_64-softmmu"
../configure                   \
    --prefix=/usr              \
    --sysconfdir=/etc          \
    --localstatedir=/var       \
    --target-list="${TARGETS}" \
    --audio-drv-list=alsa      \
    --disable-pa               \
    --enable-spice             \
    --enable-spice-protocol    \
    --enable-usb-redir         \
    --enable-slirp             \
    --disable-debug-info       \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# QEMU создает ninja подпроцесс при тестировании.
# ninja test
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}
rm -rf "${TMP_DIR}/var/run"

# Добавим правило для Udev, чтобы правильно отображались разрешения для KVM
# устройств.
cat << EOF > "${TMP_DIR}/usr/lib/udev/rules.d/65-kvm.rules"
KERNEL=="kvm", GROUP="kvm", MODE="0660"
KERNEL=="vhost-net", GROUP="kvm", MODE="0660"
EOF

# Необходимые разрешения для использование bridge обычным пользователем.
chgrp kvm  "${TMP_DIR}/usr/libexec/qemu-bridge-helper"
chmod 4750 "${TMP_DIR}/usr/libexec/qemu-bridge-helper"
echo "allow br0" > "${TMP_DIR}/etc/qemu/bridge.conf"

# Ссылка в /usr/bin
#    qemu -> qemu-system-x86_64
ln -sv qemu-system-"$(uname -m)" "${TMP_DIR}/usr/bin/qemu"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (open source processor emulator)
#
# QEMU is a generic and open source processor emulator which achieves a good
# emulation speed by using dynamic translation. Containing virtualization
# extensions (Intel VT or AMD-V)
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://download.${PRGNAME}.org/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
