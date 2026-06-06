#! /bin/bash

PRGNAME="libvirt"

### libvirt (The virtualization API)
# Главный программный комплекс для управления различными технологиями
# виртуализации в Linux из единого центра. Он предоставляет общий интерфейс для
# настройки виртуальных машин, сетей и хранилищ.

# Required:    qemu
#              libxml2
#              libyajl
#              iptables    (runtime)
#              dnsmasq
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/rc.d"

# sysctld файлы в /etc/sysctl.d/ вместо /usr/lib/sysctl
sed "s|prefix / 'lib' / 'sysctl.d'|sysconfdir / 'sysctl.d'|" \
    -i src/remote/meson.build || exit 1

# разрешим любому пользователю состоящему в группе 'kvm' подключаться к
# System Libvirtd без ввода пароля
patch --verbose -p1 < "${SOURCES}/use-virtgroup-in-polkit-rules.diff" || exit 1

VIRTGROUP="kvm"
sed -e "s,@VIRTGROUP@,$VIRTGROUP,g" -i src/remote/libvirtd.rules || exit 1

mkdir build
cd build || exit 1

meson setup ..                            \
    --prefix=/usr                         \
    --buildtype=release                   \
    --sysconfdir=/etc                     \
    --localstatedir=/var                  \
    -D qemu_user=root                     \
    -D qemu_group=kvm                     \
    -D driver_network=enabled             \
    -D firewall_backend_priority=iptables \
    -D libpcap=disabled                   \
    -D apparmor=disabled                  \
    -D selinux=disabled                   \
    -D numad=disabled                     \
    -D wireshark_dissector=disabled       \
    -D tests=disabled                     \
    -D expensive_tests=disabled           \
    -D init_script=none                   \
    -D docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

rm -rf "${TMP_DIR}/etc/logrotate.d"
rm -rf "${TMP_DIR}/run"
rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

# используем группу kvm, исправляем права авторизации и учитываем тот факт, что
# по умолчанию у нас нет сертификатов
sed \
    -e "s|^\#unix_sock_group\ =\ \"libvirt\"|unix_sock_group = \"$VIRTGROUP\"|" \
    -e "s|^\#unix_sock_rw_perms\ =\ \"0770\"|unix_sock_rw_perms = \"0770\"|" \
    -e "s|^\#auth_unix_ro.*|auth_unix_ro = \"none\"|" \
    -e "s|^\#auth_unix_rw.*|auth_unix_rw = \"none\"|" \
    -e "s|^\#listen_tls|listen_tls|" \
    -i "${TMP_DIR}/etc/libvirt/libvirtd.conf" || exit 1

# раскомментируем строку
#    #group = "root" или #group = "kvm"
# в group = "kvm"
sed \
    -e "s|^\#group\ =\ \"root\"|group = \"$VIRTGROUP\"|" \
    -e "s|^\#group\ =\ \"$VIRTGROUP\"|group = \"$VIRTGROUP\"|" \
    -i "${TMP_DIR}/etc/libvirt/qemu.conf" || exit 1

# отключим поддержку seccomp, иначе виртуальные машины не запустятся с новой
# комбинацией libvirt/qemu combo 20220212 bkw
sed -i  "s|^\#seccomp_sandbox = 1|seccomp_sandbox = 0|" \
        "${TMP_DIR}/etc/libvirt/qemu.conf" || exit 1

RC_LIBVIRT="/etc/rc.d/rc.libvirt"
cp "${SOURCES}/rc.libvirt" "${TMP_DIR}${RC_LIBVIRT}" || exit 1
chown root:root            "${TMP_DIR}${RC_LIBVIRT}"
chmod 754                  "${TMP_DIR}${RC_LIBVIRT}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
