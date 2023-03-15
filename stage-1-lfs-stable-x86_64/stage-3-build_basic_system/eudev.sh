#! /bin/bash

PRGNAME="eudev"

### Eudev (dynamic device directory system)
# Программы для динамического создания узлов устройств

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим местоположение правил udev в файле .pc
sed -i '/udevdir/a udev_dir=${udevdir}' src/udev/udev.pc.in || exit 1

./configure                \
    --prefix=/usr          \
    --bindir=/usr/sbin     \
    --sysconfdir=/etc      \
    --enable-manpages      \
    --disable-static || exit 1

make || make -j1 || exit 1

# создадим несколько каталогов, которые необходимы для тестов, а также будут
# использоваться как часть установки системы
mkdir -pv /usr/lib/udev/rules.d
mkdir -pv /etc/udev/rules.d
mkdir -pv "${TMP_DIR}/usr/lib/udev/rules.d"
mkdir -pv "${TMP_DIR}/etc/udev/rules.d"

# make check

make install DESTDIR="${TMP_DIR}"

# установим некоторые пользовательские правила и файлы поддержки из архива
# udev-lfs, которые будут полезные в среде LFS
UDEV_LFS="udev-lfs"
UDEV_LFS_VERSION="$(echo "${SOURCES}/${UDEV_LFS}"-*.tar.?z* | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"
# http://anduin.linuxfromscratch.org/LFS/udev-lfs-${UDEV_LFS_VERSION}.tar.?z*
#
# /etc
# └── udev
#     └── rules.d
#         ├── 55-lfs.rules
#         ├── 81-cdrom.rules
#         └── 83-cdrom-symlinks.rules
# /usr/lib
#       └── udev
#           ├── rules.d/
#           ├── init-net-rules.sh
#           ├── rule_generator.functions
#           ├── write_cd_rules
#           └── write_net_rules
# /usr
#     └── share
#         └── doc
#             └── udev-${UDEV_LFS_VERSION}
#                 └── lfs
#                     ├── 55-lfs.txt
#                     └── README
#
tar xvf "${SOURCES}/${UDEV_LFS}-${UDEV_LFS_VERSION}".tar.?z* || exit 1
MAKEFILE_LFS="${UDEV_LFS}-${UDEV_LFS_VERSION}/Makefile.lfs"
sed -i 's/\/lib/\/usr\/lib/' "${MAKEFILE_LFS}"               || exit 1
make -f "${MAKEFILE_LFS}" install DESTDIR="${TMP_DIR}"       || exit 1

# бэкапим конфиг /etc/udev/udev.conf перед установкой пакета
UDEV_CONF="/etc/udev/udev.conf"
if [ -f "${UDEV_CONF}" ]; then
    mv "${UDEV_CONF}" "${UDEV_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

config_file_processing "${UDEV_CONF}"

### конфигурация Eudev
# информация об аппаратных устройствах хранится в каталогах
#    /etc/udev/hwdb.d/
#    /usr/lib/udev/hwdb.d/
# Для Eudev нужно, чтобы эта информация была собрана в двоичной базе данных
#    /etc/udev/hwdb.bin
# Создадим эту исходную базу данных. Эта команда должна выполняться каждый раз,
# когда обновляется информация об оборудовании
udevadm hwdb --update
cp -v /etc/udev/hwdb.bin "${TMP_DIR}/etc/udev/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (dynamic device directory system)
#
# The Eudev package contains programs for dynamic creation of device nodes and
# provides a dynamic device directory containing only the files for the devices
# which are actually present. It creates or removes device node files usually
# located in the /dev directory. Eudev is a fork of
# https://github.com/systemd/systemd with the aim of isolating udev from any
# particular flavor of system initialization.
#
# Home page: https://wiki.gentoo.org/wiki/Project:Eudev
# Download:  https://github.com/${PRGNAME}-project/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
