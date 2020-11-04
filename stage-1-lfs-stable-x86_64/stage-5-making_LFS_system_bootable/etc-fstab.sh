#! /bin/bash

PRGNAME="etc-fstab"
SWAP_PART="/dev/sda6"
ROOT_PART="/dev/sda10"

### /etc/fstab (partition mount settings)
# /etc/fstab - файл в котором хранятся настройки монтирования различных
# разделов, включая корень и swap

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

FSTAB="/etc/fstab"
cat << EOF > "${TMP_DIR}${FSTAB}"
# Begin ${FSTAB}

# File System    mount-point    type        options             dump fsck order
# ------------------------------------------------------------------------------
${SWAP_PART}        swap           swap        defaults            0       0
${ROOT_PART}       /              ext4        defaults            1       1
proc             /proc          proc        nosuid,noexec,nodev 0       0
sysfs            /sys           sysfs       nosuid,noexec,nodev 0       0
devpts           /dev/pts       devpts      gid=5,mode=620      0       0
tmpfs            /run           tmpfs       defaults            0       0
devtmpfs         /dev           devtmpfs    mode=0755,nosuid    0       0

# End ${FSTAB}
EOF

/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}"
# Package: ${PRGNAME} (partition mount settings)
#
# /etc/fstab
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}"
