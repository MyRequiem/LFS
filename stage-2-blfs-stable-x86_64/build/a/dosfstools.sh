#! /bin/bash

PRGNAME="dosfstools"

### dosfstools (tools for working with FAT filesystems)
# Утилиты для создания, проверки и восстановления файловых систем семейства FAT

# http://www.linuxfromscratch.org/blfs/view/stable/postlfs/dosfstools.html

# Home page: https://github.com/dosfstools/dosfstools
# Download:  https://github.com/dosfstools/dosfstools/releases/download/v4.1/dosfstools-4.1.tar.xz

# Required: no
# Optional: no

### Kernel Configuration:
#    CONFIG_MSDOS_FS=m|y
#    CONFIG_VFAT_FS=m|y

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# создаем dosfsck, dosfslabel, а так жесимволические ссылки fsck.msdos,
# fsck.vfat, mkdosfs, mkfs.msdos и mkfs.vfat, необходимые для некоторых
# программ
#    --enable-compat-symlinks
./configure                  \
    --prefix=/               \
    --enable-compat-symlinks \
    --mandir=/usr/share/man  \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tools for working with FAT filesystems)
#
# The dosfstools package contains various utilities for use with the FAT family
# of file systems, utilities for creating FAT filesystems (mkdosfs), and for
# checking and repairing them (dosfsck).
#
# Home page: https://github.com/${PRGNAME}/${PRGNAME}
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
