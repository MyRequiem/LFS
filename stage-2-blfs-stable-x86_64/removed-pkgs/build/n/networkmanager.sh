#! /bin/bash

PRGNAME="networkmanager"
ARCH_NAME="NetworkManager"

### NetworkManager (Networking that Just Works)
# Набор инструментов, которые делают работу в сети простой и удобной.
# Управление сетевыми подключениями Ethernet, Wi-Fi, мобильные модемы, VPN

# Required:    libndp
# Recommended: curl
#              dhcpcd
#              glib
#              iptables
#              libpsl
#              newt                             (для сборки утилиты nmtui)
#              nss
#              polkit                           (runtime)
#              python3-pygobject3
#              elogind
#              vala
#              wpa-supplicant                   (runtime, собранный с поддержкой d-bus)
# Optional:    bluez
#              python3-dbus                     (для тестов)
#              gnutls
#              gtk-doc
#              jansson
#              libnvme
#              modemmanager
#              upower
#              valgrind
#              dnsmasq                          (https://thekelleys.org.uk/dnsmasq/doc.html)
#              firewalld                        (https://firewalld.org/)
#              libaudit                         (https://github.com/Distrotech/libaudit)
#              libteam                          (https://github.com/jpirko/libteam)
#              mobile-broadband-provider-info   (https://download.gnome.org/sources/mobile-broadband-provider-info/)
#              ppp                              (https://www.samba.org/ftp/ppp/)
#              rp-pppoe                         (https://dianne.skoll.ca/projects/rp-pppoe/)

### Конфигурация ядра
#    CONFIG_NET=y
#    CONFIG_INET=y
#    CONFIG_NET_IPIP=y|m
#    CONFIG_NET_IPGRE_DEMUX=y|m
#    CONFIG_NET_IPGRE=y|m
#    CONFIG_IPV6=y
#    CONFIG_IPV6_SIT=y|m
#    CONFIG_IPV6_GRE=y|m
#    CONFIG_IPV6_MULTIPLE_TABLES=y
#    CONFIG_MPTCP=y
#    CONFIG_MPTCP_IPV6=y
#    CONFIG_VLAN_8021Q=y|m
#    CONFIG_NET_SCHED=y
#    CONFIG_NET_SCH_SFQ=y
#    CONFIG_NET_SCH_TBF=y
#    CONFIG_NET_SCH_FQ_CODEL=y
#    CONFIG_NET_SCH_INGRESS=y
#    CONFIG_NETDEVICES=y
#    CONFIG_NET_CORE=y
#    CONFIG_BONDING=y|m
#    CONFIG_DUMMY=y|m
#    CONFIG_NET_TEAM=y|m
#    CONFIG_MACVLAN=y|m
#    CONFIG_MACVTAP=y|m
#    CONFIG_IPVLAN=y|m
#    CONFIG_VXLAN=y|m
#    CONFIG_VETH=y|m
#    CONFIG_NET_VRF=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# исправим shebang у python-скриптов на python3
grep -rl '^#!.*python$' | xargs sed -i '1s/python/&3/'

mkdir build
cd build || exit 1

meson setup ..                  \
    --prefix=/usr               \
    --buildtype=release         \
    -D libaudit=no              \
    -D nmtui=true               \
    -D ovs=true                 \
    -D ppp=false                \
    -D nbft=false               \
    -D selinux=false            \
    -D session_tracking=elogind \
    -D modem_manager=false      \
    -D systemdsystemunitdir=no  \
    -D systemd_journal=false    \
    -D nm_cloud_setup=false     \
    -D qt=false || exit 1

ninja || exit 1

#тесты проводятся в графической среде
# ninja test

DESTDIR="${TMP_DIR}" ninja install

mv -v "${TMP_DIR}/usr/share/doc"/NetworkManager{,-"${VERSION}"}

# man-страницы
for FILE in $(echo ../man/*.[1578]); do
    SECTION=${FILE##*.} &&
    install -vdm 755          "${TMP_DIR}/usr/share/man/man${SECTION}"
    install -vm 644 "${FILE}" "${TMP_DIR}/usr/share/man/man${SECTION}/"
done

# Для работы networkmanager должен существовать хотя бы минимальный файл
# конфигурации, который не устанавливается по умолчанию, поэтому создадим его.
# Этот файл не должен изменяться непосредственно пользователями системы. Вместо
# этого следует вносить изменения путем добавления конфигов в
# /etc/NetworkManager/conf.d/
cat >> "${TMP_DIR}/etc/NetworkManager/NetworkManager.conf" << "EOF"
[main]
plugins=keyfile
EOF

# разрешим polkit управлять авторизацией
cat > "${TMP_DIR}/etc/NetworkManager/conf.d/polkit.conf" << "EOF"
[main]
auth-polkit=true
EOF

cat > "${TMP_DIR}/etc/NetworkManager/conf.d/dhcp.conf" << "EOF"
[main]
dhcp=dhcpcd
EOF

# запретим NetworkManager обновлять адреса DNS в /etc/resolv.conf
cat > "${TMP_DIR}/etc/NetworkManager/conf.d/no-dns-update.conf" << "EOF"
[main]
dns=none
EOF

# чтобы позволить обычному пользователю настраивать сетевые подключения, его
# нужно добавить в группу netdev и создать правило polkit, предоставляющее
# доступ
! grep -qE "^netdev:" /etc/group  && \
    groupadd -fg 86 netdev

RULES_D="/usr/share/polkit-1/rules.d"
mkdir -p "${TMP_DIR}${RULES_D}"
cat > "${TMP_DIR}${RULES_D}/org.freedesktop.NetworkManager.rules" << "EOF"
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0 && subject.isInGroup("netdev")) {
        return polkit.Result.YES;
    }
});
EOF

# установим скрипт автозапуска
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-networkmanager DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Networking that Just Works)
#
# NetworkManager is a set of co-operative tools that make networking simple and
# straightforward. Whether you use WiFi, wired, 3G, or Bluetooth,
# NetworkManager allows you to quickly move from one network to another: Once a
# network has been configured and joined once, it can be detected and re-joined
# automatically the next time it's available.
#
# Home page: https://gitlab.freedesktop.org/${ARCH_NAME}/
# Download:  https://gitlab.freedesktop.org/${ARCH_NAME}/${ARCH_NAME}/-/releases/${VERSION}/downloads/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
