#! /bin/bash

PRGNAME="qemu"

### qemu (open source processor emulator)
# Универсальный эмулятор процессора с открытым исходным кодом, обеспечивающий
# хорошую скорость эмуляции с помощью динамического перевода. Содержит
# расширенную виртуализацию (Intel VT или AMD-V)

# Required:    glib
#              pixman
# Recommended: alsa-lib
#              dtc
#              libslirp
#              sdl2
# Optional:    pipewire или pulseaudio
#              bluez
#              curl
#              cyrus-sasl
#              fuse3
#              gnutls
#              gtk+3
#              keyutils
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
#              elogind
#              python3-sphinx-rtd-theme

capstone (https://www.capstone-engine.org/)
ceph (https://github.com/ceph/ceph/)
daxctl (https://pmem.io/daxctl/)
jack (https://jackaudio.org/)
glusterfs (https://github.com/gluster/glusterfs)
libbpf (https://github.com/libbpf/libbpf)
libcacard (https://gitlab.freedesktop.org/spice/libcacard)
libcap-ng (https://people.redhat.com/sgrubb/libcap-ng/)
libdw (https://sourceware.org/elfutils/)
libiscsi (https://github.com/sahlberg/libiscsi)
libnfs (https://github.com/sahlberg/libnfs)
libpmem (https://pmem.io/pmdk/libpmem/)
libssh (https://www.libssh.org/)
libu2f-emu (https://github.com/Agnoctopus/libu2f-emu)
lzfse (https://github.com/lzfse/lzfse)
netmap (https://github.com/luigirizzo/netmap)
numactl (https://github.com/numactl/numactl)
rdma-core (https://github.com/linux-rdma/rdma-core)
selinux (https://selinuxproject.org/page/Main_Page)
snappy (https://google.github.io/snappy/)
spice (https://gitlab.freedesktop.org/spice/spice)
usbredir (https://gitlab.freedesktop.org/spice/usbredir)
vde (https://github.com/virtualsquare/vde-2)


### Конфигурация ядра
#    CONFIG_VIRTUALIZATION=y
#    CONFIG_KVM=m
#    CONFIG_KVM_INTEL=m  (для процессоров Intel)
#    или
#    CONFIG_KVM_AMD=m    (для процессоров AMD)
#    CONFIG_NET=y
#    CONFIG_BRIDGE=m
#    CONFIG_NETDEVICES=y
#    CONFIG_TUN=m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/{lib/udev/rules.d,etc/qemu}

# добавим группу kvm, если не существует
! grep -qE "^kvm:" /etc/group  && \
    groupadd -g 61 kvm

# исправим проблему сборки с binutils-2.36
sed -i "/LDFLAGS_NOPIE/d" configure pc-bios/optionrom/Makefile || exit 1

JEMALLOC="--disable-jemalloc"
[ -x /usr/lib/libjemalloc.so ] && JEMALLOC="--enable-jemalloc"

TARGETS="i386-softmmu,x86_64-softmmu,i386-linux-user,x86_64-linux-user"
TARGETS="${TARGETS},arm-softmmu,arm-linux-user,armeb-linux-user"

AUDIO_DRIVERS="alsa,pa"

mkdir -p build
cd build || exit 1

../configure                            \
    --prefix=/usr                       \
    --sysconfdir=/etc                   \
    --localstatedir=/var                \
    --enable-gtk                        \
    --enable-system                     \
    --enable-kvm                        \
    --enable-virtfs                     \
    --enable-sdl                        \
    "${JEMALLOC}"                       \
    --enable-nettle                     \
    --target-list="${TARGETS}"          \
    --audio-drv-list="${AUDIO_DRIVERS}" \
    --disable-debug-info                \
    --mandir=/usr/share/man             \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1

# qemu для тестов использует ninja
# ninja test

make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/var/run"

# добавим правило для Udev, чтобы правильно отображались разрешения для KVM
# устройств
cat << EOF > "${TMP_DIR}/lib/udev/rules.d/65-kvm.rules"
KERNEL=="kvm", GROUP="kvm", MODE="0660"
KERNEL=="vhost-net", GROUP="kvm", MODE="0660"
EOF

# необходимые разрешения для использование bridge
chgrp kvm  "${TMP_DIR}/usr/libexec/qemu-bridge-helper"
chmod 4750 "${TMP_DIR}/usr/libexec/qemu-bridge-helper"

echo allow br0 > "${TMP_DIR}/etc/qemu/bridge.conf"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
