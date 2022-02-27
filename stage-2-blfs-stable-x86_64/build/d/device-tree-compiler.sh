#! /bin/bash

PRGNAME="device-tree-compiler"
ARCH_NAME="dtc"

### device-tree-compiler (Device Tree Compiler for Flat Device Trees)
# Device Tree Compiler, dtc, takes as input a device-tree in a given format and
# outputs a device-tree in another format for booting kernels on embedded
# systems, transforms a textual description of a device tree (DTS) into a
# binary object (DTB).

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make clean || exit 1

# сборка в один поток, иначе ошибка
make -j1 \
    PREFIX=/usr || exit 1

make -j1 PREFIX=/usr install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Device Tree Compiler for Flat Device Trees)
#
# Device Tree Compiler, dtc, takes as input a device-tree in a given format and
# outputs a device-tree in another format for booting kernels on embedded
# systems, transforms a textual description of a device tree (DTS) into a
# binary object (DTB).
#
# Home page: https://git.kernel.org/cgit/utils/${ARCH_NAME}/${ARCH_NAME}.git
# Download:  https://git.kernel.org/pub/scm/utils/${ARCH_NAME}/${ARCH_NAME}.git/snapshot/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
