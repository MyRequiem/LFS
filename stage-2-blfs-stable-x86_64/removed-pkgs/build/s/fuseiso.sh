#! /bin/bash

PRGNAME="fuseiso"

### fuseiso (FUSE module to mount ISO filesystem images)
# Модуль FUSE для монтирования образов .iso, .nrg, .bin, .mdf и .img

# Required:    fuse2 (https://github.com/libfuse/libfuse)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --disable-static  \
    --sysconfdir=/etc \
    --localstatedir=/var/lib || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (FUSE module to mount ISO filesystem images)
#
# FuseISO is a FUSE module to mount ISO filesystem images (.iso, .nrg, .bin,
# .mdf and .img files). It currently support plain ISO9660 Level 1 and 2, Rock
# Ridge, Joliet, and zisofs.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
