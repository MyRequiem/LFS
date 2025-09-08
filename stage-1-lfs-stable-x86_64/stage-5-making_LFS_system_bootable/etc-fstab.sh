#! /bin/bash

PRGNAME="etc-fstab"
LFS_VERSION="12.4"

SWAP_PART="/dev/sda2"
ROOT_PART="/dev/sda5"
BOOT_PART="/dev/sda1"
HOME_PART="/dev/sda6"
TMP_PART="/dev/sda7"

### /etc/fstab (partition mount settings)
# /etc/fstab - файл в котором хранятся настройки монтирования различных
# разделов, включая корень и swap

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

FSTAB="/etc/fstab"
cat << EOF > "${TMP_DIR}${FSTAB}"
# Begin ${FSTAB}

# File System    mount-point    type        options             dump fsck order
# ------------------------------------------------------------------------------
${SWAP_PART}       swap            swap        pri=1                0       0
${ROOT_PART}       /               ext4        defaults             1       1
${BOOT_PART}       /boot           ext4        defaults             1       2
${HOME_PART}       /home           ext4        defaults             1       2
${TMP_PART}       /tmp            ext4        defaults             1       2
proc            /proc           proc        nosuid,noexec,nodev  0       0
sysfs           /sys            sysfs       nosuid,noexec,nodev  0       0
devpts          /dev/pts        devpts      gid=5,mode=620       0       0
tmpfs           /run            tmpfs       defaults             0       0
devtmpfs        /dev            devtmpfs    mode=0755,nosuid     0       0
tmpfs           /dev/shm        tmpfs       nosuid,nodev         0       0
cgroup2         /sys/fs/cgroup  cgroup2     nosuid,noexec,nodev  0       0

# End ${FSTAB}
EOF

if [ -f "${FSTAB}" ]; then
    mv "${FSTAB}" "${FSTAB}.old"
fi

/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${FSTAB}"

rm -f "/var/log/packages/${PRGNAME}"-*

cat << EOF > "/var/log/packages/${PRGNAME}-${LFS_VERSION}"
# Package: ${PRGNAME} (partition mount settings)
#
# /etc/fstab
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${LFS_VERSION}"
