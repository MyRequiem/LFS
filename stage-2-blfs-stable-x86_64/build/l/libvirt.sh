#! /bin/bash

PRGNAME="libvirt"

### libvirt (The virtualization API)
# Набор инструментов для взаимодействия с возможностями виртуализации ядра
# Linux

# Required:    libyajl
#              python3-urlgrabber
# Recommended: no
# Optional:    no

# -----------------------------------
# depends from src code (INSTALL.md)
# -----------------------------------
# gettext
# python3
# gtk+3
# python3-libvirt
# python3-pygobject3
# libosinfo
# gtksourceview3

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/rc.d/"

# sysctld файлы в /etc/sysctl.d/ вместо /usr/lib/sysctl
sed "s|%{_prefix}/lib/sysctl|%{_sysconfdir}/sysctl|" \
    -i libvirt.spec* || exit 1
sed "s|prefix / 'lib' / 'sysctl.d'|sysconfdir / 'sysctl.d'|" \
    -i src/remote/meson.build || exit 1

VIRTUSER="root"
VIRTGROUP="kvm"
BASH_COMPLETION=""
BASH_COMPLETION_DIR=""
BASH_COMPLETION_DIR_PATH="/usr/share/bash-completion/completions"
AUDIT="disabled"
LIBISCSI="disabled"

if pkg-config --exists bash-completion; then
    BASH_COMPLETION="-Dbash_completion=enabled"
    BASH_COMPLETION_DIR="-Dbash_completion_dir=${BASH_COMPLETION_DIR_PATH}"
fi

pkg-config --exists audit    && AUDIT="enabled"
pkg-config --exists libiscsi && LIBISCSI="enabled"

mkdir build
cd build || exit 1

meson                              \
    --prefix=/usr                  \
    --buildtype=release            \
    --sysconfdir=/etc              \
    --localstatedir=/var           \
    -Dtests=disabled               \
    -Dqemu_user="${VIRTUSER}"      \
    -Dqemu_group="${VIRTGROUP}"    \
    -Dexpensive_tests=disabled     \
    "${BASH_COMPLETION}"           \
    "${BASH_COMPLETION_DIR}"       \
    -Daudit="${AUDIT}"             \
    -Dlibiscsi="${LIBISCSI}"       \
    -Dopenwsman=disabled           \
    -Dapparmor=disabled            \
    -Dselinux=disabled             \
    -Dwireshark_dissector=disabled \
    -Ddriver_bhyve=disabled        \
    -Ddriver_hyperv=disabled       \
    -Ddriver_libxl=disabled        \
    -Ddriver_vz=disabled           \
    -Dsecdriver_apparmor=disabled  \
    -Dsecdriver_selinux=disabled   \
    -Dstorage_sheepdog=disabled    \
    -Dstorage_vstorage=disabled    \
    -Ddtrace=disabled              \
    -Dinit_script=none             \
    -Ddocs=enabled                 \
    -Ddocdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

ninja || exit 1

# для тестов устанавливаем параметр -Dtests=enabled
# ninja test

DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/var/run"

# add an rc.libvirt to start/stop/restart the daemon
# install -D -m 0755 $CWD/rc.libvirt $PKG/etc/rc.d/rc.libvirt.new

# используем группу kvm, исправляем права авторизации и учитываем тот факт, что
# по умолчанию у нас нет сертификатов
sed \
    -e "s|^\#unix_sock_group\ =\ \"libvirt\"|unix_sock_group = \"$VIRTGROUP\"|" \
    -e "s|^\#unix_sock_rw_perms\ =\ \"0770\"|unix_sock_rw_perms = \"0770\"|" \
    -e "s|^\#auth_unix_ro.*|auth_unix_ro = \"none\"|" \
    -e "s|^\#auth_unix_rw.*|auth_unix_rw = \"none\"|" \
    -e "s|^\#listen_tls|listen_tls|" \
    -i "${TMP_DIR}/etc/libvirt/libvirtd.conf" || exit 1

sed \
    -e "s|^\#group\ =\ \"root\"|group = \"$VIRTGROUP\"|" \
    -i "${TMP_DIR}/etc/libvirt/qemu.conf" || exit 1

# отключим поддержку seccomp, иначе виртуальные машины не запустятся с новой
# комбинацией libvirt/qemu combo 20220212 bkw
if [ -e "${TMP_DIR}/etc/libvirt/qemu.conf" ]; then
    sed \
        "s|^\#seccomp_sandbox = 1|seccomp_sandbox = 0|" \
        -i "${TMP_DIR}/etc/libvirt/qemu.conf" || exit 1
fi

RC_LIBVIRT="/etc/rc.d/rc.libvirt"
cp "${SOURCES}/rc.libvirt" "${TMP_DIR}${RC_LIBVIRT}"
chown root:root            "${TMP_DIR}${RC_LIBVIRT}"
chmod 754                  "${TMP_DIR}${RC_LIBVIRT}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (The virtualization API)
#
# libvirt is a toolkit to interact with the virtualization capabilities of
# recent versions of Linux (and other OSes)
#
# Home page: https://${PRGNAME}.org
# Download:  https://${PRGNAME}.org/sources/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
