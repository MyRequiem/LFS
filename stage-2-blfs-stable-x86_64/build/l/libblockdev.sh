#! /bin/bash

PRGNAME="libblockdev"

### libblockdev (library for manipulation of block devices)
# C-библиотека, поддерживающая GObject Introspection для управления блочными
# устройствами.

# Required:    libbytesize
#              libyaml
#              parted
#              volume-key
# Recommended: no
# Optional:    btrfs-progs
#              gtk-doc
#              mdadm
#              dmraid    (https://people.redhat.com/~heinzm/sw/dmraid/)
#              bcachefs  (https://bcachefs.org/)
#              ndctl     (https://github.com/pmem/ndctl)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --with-python3    \
    --without-gtk-doc \
    --without-btrfs   \
    --without-dmraid  \
    --without-nvdimm  \
    --without-dm || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (library for manipulation of block devices)
#
# libblockdev is a C library supporting GObject Introspection for manipulation
# of block devices. It has a plugin-based architecture where each technology
# (like LVM, Btrfs, MD RAID, Swap,...) is implemented in a separate plugin,
# possibly with multiple implementations (e.g. using LVM CLI or the new LVM
# DBus API).
#
# Home page: https://github.com/storaged-project/${PRGNAME}/
# Download:  https://github.com/storaged-project/${PRGNAME}/releases/download/${VERSION}-1/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
