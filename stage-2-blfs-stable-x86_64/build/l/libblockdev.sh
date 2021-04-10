#! /bin/bash

PRGNAME="libblockdev"

### libblockdev (library for manipulation of block devices)
# C-библиотека, поддерживающая GObject Introspection для управления блочными
# устройствами.

# Required:    gobject-introspection
#              libbytesize
#              libyaml
#              parted
#              volume-key
# Recommended: no
# Optional:    btrfs-progs
#              gtk-doc
#              mdadm
#              dmraid    (http://people.redhat.com/~heinzm/sw/dmraid/)
#              bcachefs  (https://bcachefs.org/)
#              ndctl     (https://github.com/pmem/ndctl)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--without-gtk-doc"
PYTHON2="--without-python2"
BTRFS="--without-btrfs"
DMRAID="--without-dmraid"
NDCTL="--without-nvdimm"

# command -v gtkdoc-check &>/dev/null && GTK_DOC="--with-gtk-doc"
command -v python2      &>/dev/null && PYTHON2="--with-python2"
command -v btrfs        &>/dev/null && BTRFS="--with-btrfs"
command -v dmraid       &>/dev/null && DMRAID="--with-dmraid"
[ -x /usr/lib/libndctl.so ]         && NDCTL="--with-nvdimm"

./configure        \
    --prefix=/usr  \
    --with-python3 \
    "${GTK_DOC}"   \
    "${PYTHON2}"   \
    "${BTRFS}"     \
    "${DMRAID}"    \
    "${NDCTL}"     \
    --without-dm   \
    --sysconfdir=/etc || exit 1

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
