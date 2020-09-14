#! /bin/bash

PRGNAME="etc-lfs-release"
VERSION="stable"

### /etc/lfs-release (system info)
# /etc/lfs-release - содержит версию LFS системы
# /etc/lsb-release - информация о системе
# /etc/os-release  - информация о системе, которая используется некоторыми
#                       графическими средами рабочего стола

# http://www.linuxfromscratch.org/lfs/view/stable/chapter09/theend.html

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

LFS_RELEASE="/etc/lfs-release"
if [ -f "${LFS_RELEASE}" ]; then
    mv "${LFS_RELEASE}" "${LFS_RELEASE}.old"
fi

echo "${VERSION}" > "${LFS_RELEASE}"
cp "${LFS_RELEASE}" "${TMP_DIR}/etc/"
config_file_processing "${LFS_RELEASE}"

# также неплохо создать файл /etc/lsb-release содержащий информацию о системе в
# соответствии с базой стандартов Linux (LSB)
LSB_RELEASE="/etc/lsb-release"
if [ -f "${LSB_RELEASE}" ]; then
    mv "${LSB_RELEASE}" "${LSB_RELEASE}.old"
fi

cat << EOF > "${LSB_RELEASE}"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="${VERSION}"
DISTRIB_CODENAME="MyRequiem-LFS"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cp "${LSB_RELEASE}" "${TMP_DIR}/etc/"
config_file_processing "${LSB_RELEASE}"

OS_RELEASE="/etc/os-release"
if [ -f "${OS_RELEASE}" ]; then
    mv "${OS_RELEASE}" "${OS_RELEASE}.old"
fi

cat << EOF > "${OS_RELEASE}"
NAME="Linux From Scratch"
VERSION="${VERSION}"
ID=lfs
PRETTY_NAME="Linux From Scratch ${VERSION}"
VERSION_CODENAME="MyRequiem-LFS"
EOF

cp "${OS_RELEASE}" "${TMP_DIR}/etc/"
config_file_processing "${OS_RELEASE}"

cat << EOF > "/var/log/packages/${PRGNAME}"
# Package: ${PRGNAME} (system info)
#
# /etc/lfs-release
# /etc/lsb-release
# /etc/os-release
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}"
