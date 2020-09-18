#! /bin/bash

PRGNAME="udisks"

### UDisks (storage device daemon)
# Демон реализующий D-Bus интерфейсы, инструменты и библиотеки для доступа и
# управления дисками и другими устройствами хранения данных.

# http://www.linuxfromscratch.org/blfs/view/stable/general/udisks2.html

# Home page: http://www.freedesktop.org/wiki/Software/udisks
# Download:  https://github.com/storaged-project/udisks/releases/download/udisks-2.8.4/udisks-2.8.4.tar.bz2

# Required:    libatasmart
#              libblockdev
#              libgudev
#              libxslt
#              polkit
# Recommended: elogind
# Optional:    gtk-doc
#              btrfs-progs
#              dbus
#              dosfstools
#              gptfdisk
#              mdadm
#              xfsprogs
#              gobject-introspection (требуется при сборке GNOME)
#              python-d-bus          (для тестов)
#              lvm2
#              ntfs-3g
#              python-pygobject3     (для тестов)
#              exfat                 (https://github.com/relan/exfat)
#              libiscsi              (https://github.com/sahlberg/libiscsi)

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GTK_DOC="--disable-gtk-doc"
BTRFS="--disable-btrfs"
LVM2="--disable-lvm2"
ISCSI="--disable-iscsi"

command -v gtkdoc-check &>/dev/null && GTK_DOC="--enable-gtk-doc"
command -v btrfs        &>/dev/null && BTRFS="--enable-btrfs"
command -v fsadm        &>/dev/null && LVM2="--enable-lvm2"
[ -x /usr/lib/libiscsi.so ]         && ISCSI="--enable-iscsi"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --disable-static  \
    "${GTK_DOC}"      \
    "${BTRFS}"        \
    "${LVM2}"         \
    "${ISCSI}"        \
    --localstatedir=/var || exit 1

make || exit 1

# Перед запуском тестов должны быть установлены опциональные пакеты
# gobject-introspection, python-d-bus и python-pygobject3, а также должны
# существовать каталоги:
#    /var/run/udisks2
#    /var/lib/udisks2
#
# make check
#
# более тщательные тесты:
# make ci

make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (storage device daemon)
#
# The udisks project provides a storage daemon that implements D-Bus interfaces
# that can be used to query and manipulate storage devices. It also includes a
# command-line tool, that can be used to query and control the daemon.
#
# Home page: http://www.freedesktop.org/wiki/Software/${PRGNAME}
# Download:  https://github.com/storaged-project/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
