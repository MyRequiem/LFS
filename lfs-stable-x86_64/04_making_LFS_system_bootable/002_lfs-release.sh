#! /bin/bash

PRGNAME="lfs-release"
VERSION="9.0"

### lfs-release
# /etc/lfs-release - содержит версию LFS системы
# /etc/lsb-release - информация о системе

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter09/theend.html

ROOT="/"
source "${ROOT}check_environment.sh"      || exit 1
source "${ROOT}config_file_processing.sh" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
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

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (system info)
#
# /etc/lfs-release
# /etc/lsb-release
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
