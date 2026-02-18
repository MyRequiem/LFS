#! /bin/bash

PRGNAME="udisks"

### UDisks (storage device daemon)
# Демон реализующий D-Bus интерфейсы, инструменты и библиотеки для доступа и
# управления дисками и другими устройствами хранения данных.

# Required:    libatasmart
#              libblockdev
#              libgudev
#              polkit
# Recommended: elogind
# Optional:    glib
#              python3-dbus          (для тестов)
#              gtk-doc
#              libxslt
#              lvm2
#              python3-pygobject3    (для тестов)
#              exfat                 (https://github.com/relan/exfat)
#              libiscsi              (https://github.com/sahlberg/libiscsi)
#              --- runtime ---
#              btrfs-progs
#              dbus
#              dosfstools
#              gptfdisk
#              mdadm
#              xfsprogs

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --disable-static     \
    --enable-available-modules || exit 1

make || exit 1

# Перед запуском тестов должны быть установлены опциональные пакеты
# python3-dbus и python3-pygobject3, а также должны существовать каталоги:
#    /var/run/udisks2
#    /var/lib/udisks2
#
# mkdir -p /var/run/udisks2
# mkdir -p /var/lib/udisks2
# make check
#
# более тщательные тесты:
# make ci

make install DESTDIR="${TMP_DIR}"
rm -rf "${TMP_DIR}/usr/share/gtk-doc"

MOUNT_OPTIONS_CONF="/etc/udisks2/mount_options.conf"
cp "${TMP_DIR}${MOUNT_OPTIONS_CONF}.example" "${TMP_DIR}${MOUNT_OPTIONS_CONF}"

if [ -f "${MOUNT_OPTIONS_CONF}" ]; then
    mv "${MOUNT_OPTIONS_CONF}" "${MOUNT_OPTIONS_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${MOUNT_OPTIONS_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (storage device daemon)
#
# The udisks project provides a storage daemon that implements D-Bus interfaces
# that can be used to query and manipulate storage devices. It also includes a
# command-line tool, that can be used to query and control the daemon.
#
# Home page: https://www.freedesktop.org/wiki/Software/${PRGNAME}/
# Download:  https://github.com/storaged-project/${PRGNAME}/releases/download/${PRGNAME}-${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
