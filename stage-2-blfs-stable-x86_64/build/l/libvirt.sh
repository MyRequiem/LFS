#! /bin/bash

PRGNAME="libvirt"

### libvirt (The virtualization API)
# Набор инструментов для взаимодействия с возможностями виртуализации ядра
# Linux

# Required:    gtk+3
#              libyajl
#              iptables
#              dnsmasq
#              python3-pygobject3
#              python3-urlgrabber
#              libosinfo
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-[0-9]*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar -xvJf "${SOURCES}/${PRGNAME}-${VERSION}".tar.xz* || exit 1
cd "${PRGNAME}-${VERSION}" || exit 1

chown -R root:root .
find -L . \
    \( -perm 777 -o -perm 775 -o -perm 750 -o -perm 711 -o -perm 555 \
    -o -perm 511 \) -exec chmod 755 {} \; -o \
    \( -perm 666 -o -perm 664 -o -perm 640 -o -perm 600 -o -perm 444 \
    -o -perm 440 -o -perm 400 \) -exec chmod 644 {} \;

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc/rc.d/"

# sysctld файлы в /etc/sysctl.d/ вместо /usr/lib/sysctl
sed "s|prefix / 'lib' / 'sysctl.d'|sysconfdir / 'sysctl.d'|" \
    -i src/remote/meson.build

# разрешим любому пользователю состоящему в группе 'kvm' подключаться к
# System Libvirtd без ввода пароля
patch --verbose -p1 < "${SOURCES}/use-virtgroup-in-polkit-rules.diff" || exit 1

VIRTGROUP="kvm"
sed -e "s,@VIRTGROUP@,$VIRTGROUP,g" -i src/remote/libvirtd.rules || exit 1

mkdir build
cd build || exit 1

meson setup ..                  \
    --prefix=/usr               \
    --buildtype=release         \
    --sysconfdir=/etc           \
    --localstatedir=/var        \
    -D qemu_user=root           \
    -D qemu_group=kvm           \
    -D tests=disabled           \
    -D expensive_tests=disabled \
    -D init_script=none         \
    -D docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

ninja || exit 1
# ninja test
DESTDIR="${TMP_DIR}" ninja install

(
    cd "${TMP_DIR}" || exit 1
    rm -rf {etc/logrotate.d,run,usr/share/doc}
)

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
