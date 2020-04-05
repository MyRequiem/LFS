#! /bin/bash

PRGNAME="etc_fstab"
VERSION="9.0"

### etc_fstab
# /etc/fstab - файл в котором хранятся настройки монтирования различных
# разделов, включая корень и swap

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter08/fstab.html

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

FSTAB="/etc/fstab"
if [ -f "${FSTAB}" ]; then
    mv "${FSTAB}" "${FSTAB}.old"
fi

cat << EOF > "${FSTAB}"
# Begin ${FSTAB}

# File System    mount-point    type        options             dump fsck order
# ------------------------------------------------------------------------------
/dev/sda6        swap           swap        defaults            0       0
/dev/sda10       /              ext4        defaults            1       1
proc             /proc          proc        nosuid,noexec,nodev 0       0
sysfs            /sys           sysfs       nosuid,noexec,nodev 0       0
devpts           /dev/pts       devpts      gid=5,mode=620      0       0
tmpfs            /run           tmpfs       defaults            0       0
devtmpfs         /dev           devtmpfs    mode=0755,nosuid    0       0

# End ${FSTAB}
EOF

cp "${FSTAB}" "${TMP_DIR}/etc/"
config_file_processing "${FSTAB}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (partition mount settings)
#
# /etc/fstab
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
