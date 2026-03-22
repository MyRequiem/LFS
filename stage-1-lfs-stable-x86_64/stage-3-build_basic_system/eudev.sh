#! /bin/bash

PRGNAME="eudev"

### Eudev (dynamic device directory system)
# Диспетчер устройств, который автоматически определяет подключенное
# оборудование (флешки, мышки и т.д.) и создает нужные файлы для работы с ними.

ROOT="/"
source "${ROOT}check_environment.sh" || exit 1

# удалим пакет udev если он установлен (при переходе с LFS < 13.x на >=13.x)
UDEV_PKG="$(find /var/log/packages/ -type f -name "udev-[0-9]*")"
if [ -n "${UDEV_PKG}" ]; then
    UDEV_VERSION="$(echo "${UDEV_PKG}" | rev | cut -d / -f 1 | rev)"
    echo "Package ${UDEV_VERSION} is installed. Before building and "
    echo "installing ${PRGNAME} package, ${UDEV_VERSION} must be removed !!!"
    echo ""
    removepkg --backup --no-color "${UDEV_PKG}"
fi

source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# в правилах Eudev по умолчанию закомментируем ненужную группу sgx, иначе будет
# засорять лог сообщениями, что такой группы не существует
sed '/sgx/s/^/# /' -i rules/50-udev-default.rules || exit 1

if ! [ -r configure ]; then
    if [ -x ./autogen.sh ]; then
        NOCONFIGURE=1 ./autogen.sh
    else
        autoreconf -vif
    fi
fi

./configure                    \
    --prefix=/usr              \
    --sysconfdir=/etc          \
    --localstatedir=/var       \
    --with-rootprefix=/usr     \
    --with-rootlibdir=/usr/lib \
    --with-rootrundir=/run     \
    --disable-manpages         \
    --enable-hwdb              \
    --enable-kmod              \
    --enable-blkid             \
    --enable-rule_generator    \
    --disable-static           \
    --disable-introspection    \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || make -j1 || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

ln -svf ../bin/udevadm "${TMP_DIR}/usr/sbin/udevadm"

# некоторые правила от Patrick J. Volkerding (Slackware) и Gemini :)
cat > "${TMP_DIR}/etc/udev/rules.d/60-lfs-desktop.rules" << "EOF"
# Slackware permission rules
#
# These rules are here instead of 40-slackware.rules because many of them need
# to run after the block section in 50-udev.default.rules
#

# all disks with group disk
KERNEL!="fd*", SUBSYSTEM=="block", GROUP="disk"

# put all removable devices in group "plugdev"
KERNEL=="sd*[!0-9]", ATTR{removable}=="1", GROUP="plugdev"
KERNEL=="sd*[0-9]", ATTRS{removable}=="1", GROUP="plugdev"

# Many hot-pluggable devices (ZIP, Jazz, LS-120, etc...)
# need to be in plugdev, too.
KERNEL=="diskonkey*",    GROUP="plugdev"
KERNEL=="jaz*",          GROUP="plugdev"
KERNEL=="pocketzip*",    GROUP="plugdev"
KERNEL=="zip*",          GROUP="plugdev"
KERNEL=="ls120",         GROUP="plugdev"
KERNEL=="microdrive*",   GROUP="plugdev"

# CD group and permissions
ENV{ID_CDROM}=="?*",     GROUP="cdrom", MODE="0660"
KERNEL=="pktcdvd",       GROUP="cdrom", MODE="0660"
KERNEL=="pktcdvd[0-9]*", GROUP="cdrom", MODE="0660"

# permissions for SCSI sg devices
SUBSYSTEMS=="scsi", KERNEL=="s[gt][0-9]*", ATTRS{type}=="5", \
    GROUP="cdrom", MODE="0660"

# make DRI video devices usable by anyone in group "video":
KERNEL=="card[0-9]*", GROUP:="video"

EOF

UDEV_LFS="udev-lfs"
UDEV_LFS_VERSION="$(echo "${SOURCES}/${UDEV_LFS}"-*.tar.?z* | rev | \
    cut -d . -f 3- | cut -d - -f 1 | rev)"

# установим некоторые пользовательские правила, которые будут полезные в LFS
# (читаем сразу из архива udev-lfs-${VERSION}.tar.xz без его распаковки)
tar -xOf "${SOURCES}/${UDEV_LFS}-${UDEV_LFS_VERSION}.tar.xz" \
    "${UDEV_LFS}-${UDEV_LFS_VERSION}/55-lfs.rules" >         \
    "${TMP_DIR}/etc/udev/rules.d/55-lfs.rules"

# изменим /usr/lib/udev/rule_generator.functions, как предлагает LFS
tar -xOf "${SOURCES}/${UDEV_LFS}-${UDEV_LFS_VERSION}.tar.xz"     \
    "${UDEV_LFS}-${UDEV_LFS_VERSION}/rule_generator.functions" | \
    sed "s|^PATH=.*|PATH='/usr/sbin:/usr/bin'|" >                \
    "${TMP_DIR}/usr/lib/udev/rule_generator.functions"

# добавим /usr/lib/udev/{init-net-rules.sh,write_net_rules}
tar -xOf "${SOURCES}/${UDEV_LFS}-${UDEV_LFS_VERSION}.tar.xz" \
    "${UDEV_LFS}-${UDEV_LFS_VERSION}/init-net-rules.sh" >    \
    "${TMP_DIR}/usr/lib/udev/init-net-rules.sh"

tar -xOf "${SOURCES}/${UDEV_LFS}-${UDEV_LFS_VERSION}.tar.xz" \
    "${UDEV_LFS}-${UDEV_LFS_VERSION}/write_net_rules" >      \
    "${TMP_DIR}/usr/lib/udev/write_net_rules"

chmod 755 "${TMP_DIR}/usr/lib/udev/init-net-rules.sh"
chmod 755 "${TMP_DIR}/usr/lib/udev/write_net_rules"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

### Конфигурация Udev
# информация об аппаратных устройствах хранится в каталогах
#    /etc/udev/hwdb.d/
# для Eudev нужно, чтобы эта информация была собрана в двоичной базе данных
#    /etc/udev/hwdb.bin
# создадим эту исходную базу данных
udevadm hwdb --update

cp -v /etc/udev/hwdb.bin "${TMP_DIR}/etc/udev/" || exit 1

# обновим dynamic linker run‐time bindings
ldconfig

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (dynamic device directory system)
#
# eudev provides a dynamic device directory containing only the files for the
# devices which are actually present. It creates or removes device node files
# usually located in the /dev directory. Eudev is a fork of Systemd with the
# aim of isolating udev from any particular flavor of system initialization.
#
# Home page: https://github.com/${PRGNAME}-project/${PRGNAME}
# Download:  https://github.com/${PRGNAME}-project/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
