#! /bin/bash

PRGNAME="lvm2"
ARCH_NAME="LVM2"

### LVM2 (Logical Volume Manager version 2)
# Подсистема, добавляющая уровень абстракции между физическими/логическими
# дисками и файловой системой и позволяющая использовать разные области одного
# жёсткого диска и/или области с разных жёстких дисков как один логический том.

# Required:    libaio
# Recommended: no
# Optional:    mdadm
#              valgrind
#              which
#              xfsprogs
#              reiserfsprogs
#              thin-provisioning-tools (https://github.com/jthornber/thin-provisioning-tools)
#              vdo                     (https://github.com/dm-vdo/vdo)

### Конфигурация ядра
#    CONFIG_BLK_DEV=y
#    CONFIG_BLK_DEV_RAM=m|y
#    CONFIG_MD=y
#    CONFIG_BLK_DEV_DM=m|y
#    CONFIG_DM_CRYPT=m|y
#    CONFIG_DM_SNAPSHOT=m|y
#    CONFIG_DM_THIN_PROVISIONING=m|y
#    CONFIG_DM_CACHE=m|y
#    CONFIG_DM_MIRROR=m|y
#    CONFIG_DM_ZERO=m|y
#    CONFIG_DM_DELAY=m|y
#    CONFIG_MAGIC_SYSRQ=y

ROOT="/root/src/lfs"
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

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# создаем shared библиотеку команд для сборки демона событий
#    --enable-cmdlib
# установливаем файлы поддержки для pkg-config
#    --enable-pkgconfig
# включаем синхронизацию с Udev
#    --enable-udev_sync
./configure                       \
    --prefix=/usr                 \
    --enable-cmdlib               \
    --enable-pkgconfig            \
    --enable-udev_sync || exit 1

make || exit 1

### тесты
# тесты используют udev для синхронизации логических томов, поэтому правила LVM
# udev и некоторые утилиты из пакета lvm2 должны быть уже установлены. Если мы
# устанавливаем LVM2 в первый раз, то установим минимальный набор утилит для
# запуска тестов:
# if ! command -v lvm &>/dev/null; then
#     make -C tools install_tools_dynamic || exit 1
#     make -C udev  install
#     make -C libdm install
# fi
#
# запускаем тесты
# LC_ALL=en_US.UTF-8 make check_local

make install DESTDIR="${TMP_DIR}"

# удалим правило, которое выполняется в другом скрипте
rm -f "${TMP_DIR}/usr/lib/udev/rules.d/69-dm-lvm.rules"

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

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

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
