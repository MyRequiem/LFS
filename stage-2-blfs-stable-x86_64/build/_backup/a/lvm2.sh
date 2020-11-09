#! /bin/bash

PRGNAME="lvm2"
ARCH_NAME="LVM2"

### LVM2 (Logical Volume Manager version 2)
# Подсистема, добавляющая уровень абстракции между физическими/логическими
# дисками и файловой системой и позволяющая использовать разные области одного
# жёсткого диска и/или области с разных жёстких дисков как один логический том.

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/lvm2.html

# Home page: https://github.com/lvmteam/lvm2/
# Download:  https://sourceware.org/ftp/lvm2/LVM2.2.03.08.tgz

# Required: libaio
# Optional: mdadm
#           reiserfsprogs
#           valgrind
#           which
#           xfsprogs
#           thin-provisioning-tools (https://github.com/jthornber/thin-provisioning-tools)

### Конфигурация ядра
#    CONFIG_MD=y
#    CONFIG_BLK_DEV_DM=m|y
#    CONFIG_DM_CRYPT=m|y
#    CONFIG_DM_SNAPSHOT=m|y
#    CONFIG_DM_THIN_PROVISIONING=m|y
#    CONFIG_DM_MIRROR=m|y
#    CONFIG_MAGIC_SYSRQ=y

ROOT="/root"
source "${ROOT}/check_environment.sh"      || exit 1
source "${ROOT}/config_file_processing.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find ${SOURCES} -type f -name "${ARCH_NAME}*.t?z" 2>/dev/null | \
    head -n 1 | cut -d . -f 2,3,4)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}.${VERSION}".t?z || exit 1
cd "${ARCH_NAME}.${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

SAVEPATH="${PATH}"             && \
PATH="${PATH}:/sbin:/usr/sbin" && \
./configure                       \
    --prefix=/usr                 \
    --exec-prefix=                \
    --enable-cmdlib               \
    --enable-pkgconfig            \
    --enable-udev_sync || exit 1

make || exit 1

PATH="${SAVEPATH}" && unset SAVEPATH

### тесты
# используют udev для синхронизации логических томов, поэтому правила LVM
# udev и некоторые утилиты должны быть установлены до запуска тестов. Если мы
# устанавливаем LVM2 в первый раз, то установим минимальный набор утилит для
# запуска тестов:
# if ! command -v lvm &>/dev/null; then
#     make -C tools install_tools_dynamic || exit 1
#     make -C udev  install
#     make -C libdm install
# fi
#
# запускаем тесты
# make check_local

# конфиг /etc/lvm/lvm.conf
LVM_CONF="/etc/lvm/lvm.conf"
if [ -f "${LVM_CONF}" ]; then
    mv "${LVM_CONF}" "${LVM_CONF}.old"
fi

# конфиг /etc/lvm/lvmlocal.conf
LVMLOCAL_CONF="/etc/lvm/lvmlocal.conf"
if [ -f "${LVMLOCAL_CONF}" ]; then
    mv "${LVMLOCAL_CONF}" "${LVMLOCAL_CONF}.old"
fi

make install
make install DESTDIR="${TMP_DIR}"

config_file_processing "${LVM_CONF}"
config_file_processing "${LVMLOCAL_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Logical Volume Manager version 2)
#
# The LVM2 package is a set of tools that manage logical partitions. It allows
# spanning of file systems across multiple physical disks and disk partitions
# and provides for dynamic growing or shrinking of logical partitions,
# mirroring and low storage footprint snapshots.
#
# Home page: https://github.com/lvmteam/${PRGNAME}/
# Download:  https://sourceware.org/ftp/${PRGNAME}/${ARCH_NAME}.${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
