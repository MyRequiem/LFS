#! /bin/bash

PRGNAME="libblockdev"

### libblockdev (library for manipulation of block devices)
# C-библиотека, поддерживающая GObject Introspection для управления блочными
# устройствами.

# Required:    glib
# Recommended: cryptsetup
#              keyutils
#              libatasmart
#              libbytesize
#              libnvme
#              lvm2
# Optional:    btrfs-progs
#              gtk-doc
#              json-glib
#              mdadm
#              parted
#              smartmontools
#              volume-key       (https://github.com/felixonmars/volume_key)
#              ndctl            (https://github.com/pmem/ndctl)
#              targetcli        (https://github.com/Datera/targetcli)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure            \
    --prefix=/usr      \
    --sysconfdir=/etc  \
    --with-python3     \
    --without-escrow   \
    --without-gtk-doc  \
    --without-lvm      \
    --without-lvm_dbus \
    --without-nvdimm   \
    --without-tools || exit 1

make || exit 1
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
# Download:  https://github.com/storaged-project/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
