#! /bin/bash

PRGNAME="python3-libvirt"
ARCH_NAME="libvirt-python"

### python3-libvirt (python bindings for libvirt)
# Привязки Python3 для libvirt

# Required:    libyajl
#              libvirt
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

python3 setup.py build || exit 1
python3 setup.py install --optimize=1 --root="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (python bindings for libvirt)
#
# This package provides a python binding to the libvirt.so, libvirt-qemu.so,
# and libvirt-lxc.so library API's
#
# Home page: https://libvirt.org
# Download:  https://libvirt.org/sources/python/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
