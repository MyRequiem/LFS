#! /bin/bash

PRGNAME="etc-lfs-release"
LFS_VERSION="12.4"

### /etc/lfs-release (system info)
# /etc/lfs-release - содержит версию LFS системы
# /etc/lsb-release - информация о системе
# /etc/os-release  - информация о системе, которая используется systemd и
#                       некоторыми графическими средами рабочего стола

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}/etc"

LFS_RELEASE="/etc/lfs-release"
echo "${LFS_VERSION}" > "${TMP_DIR}${LFS_RELEASE}"

LSB_RELEASE="/etc/lsb-release"
cat << EOF > "${TMP_DIR}${LSB_RELEASE}"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="${LFS_VERSION}"
DISTRIB_CODENAME="MyRequiem"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

OS_RELEASE="/etc/os-release"
cat << EOF > "${TMP_DIR}${OS_RELEASE}"
NAME="Linux From Scratch"
VERSION="${LFS_VERSION}"
ID=lfs
PRETTY_NAME="Linux From Scratch ${LFS_VERSION}"
VERSION_CODENAME="MyRequiem"
HOME_URL="https://www.linuxfromscratch.org/lfs/"
RELEASE_TYPE="stable"
EOF

if [ -f "${LFS_RELEASE}" ]; then
    mv "${LFS_RELEASE}" "${LFS_RELEASE}.old"
fi

if [ -f "${LSB_RELEASE}" ]; then
    mv "${LSB_RELEASE}" "${LSB_RELEASE}.old"
fi

if [ -f "${OS_RELEASE}" ]; then
    mv "${OS_RELEASE}" "${OS_RELEASE}.old"
fi

/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${LFS_RELEASE}"
config_file_processing "${LSB_RELEASE}"
config_file_processing "${OS_RELEASE}"

rm -f "/var/log/packages/${PRGNAME}"-*

cat << EOF > "/var/log/packages/${PRGNAME}-${LFS_VERSION}"
# Package: ${PRGNAME} (system info)
#
# /etc/lfs-release
# /etc/lsb-release
# /etc/os-release
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${LFS_VERSION}"
