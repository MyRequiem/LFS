#! /bin/bash

PRGNAME="iptables"

### Iptables (IP packet filter administration)
# Стандартный интерфейс управления работой межсетевого экрана (брандмауэра)
# netfilter ядра Linux.

# Required:    no
# Recommended: no
# Optional:    libpcap                (для сборки утилиты конфигурации nfsynproxy)
#              bpf-utils              (для поддержки berkely packet filter) https://github.com/tadamdam/bpf-utils
#              libnfnetlink           (для поддержки connlabel) https://netfilter.org/projects/libnfnetlink/
#              libnetfilter-conntrack (для поддержки connlabel) https://netfilter.org/projects/libnetfilter_conntrack/
#              nftables               (для поддержки connlabel) https://netfilter.org/projects/nftables/

# Брандмауэр в Linux управляется через интерфейс netfilter ядра Linux. Чтобы
# использовать iptables для настройки netfilter, необходимы следующие параметры
# конфигурации ядра:
#
#    CONFIG_NET=y
#    CONFIG_NETFILTER=y
#    CONFIG_NETFILTER_ADVANCED=y
#    CONFIG_NF_CONNTRACK=y|m
#    CONFIG_NETFILTER_XTABLES=y|m
#    CONFIG_NETFILTER_XT_TARGET_LOG=y|m
#    CONFIG_IP_NF_IPTABLES=y|m
#
# Note:
#    При обновлении ядра linux пакет необходимо пересобирать

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"/{usr/bin,lib}

LIBNETFILTER="--disable-connlabel"
LIBPCAP="--disable-nfsynproxy"
BPF_COMPILER="--disable-bpf-compiler"
NFTABLES="--disable-nftables"

[ -x /usr/lib/libnetfilter_conntrack.so ] &&  LIBNETFILTER="--enable-connlabel"
command -v pcap-config &>/dev/null && LIBPCAP="--enable-nfsynproxy"
command -v bpf-test    &>/dev/null && BPF_COMPILER="--enable-bpf-compiler"
command -v nft         &>/dev/null && NFTABLES="--enable-nftables"

# собирать библиотеку libipq.so, которая используется некоторыми пакетами за
# пределами BLFS
#    --enable-libipq
# все модули iptables установливаются в /lib/xtables
#    --with-xtlibdir=/lib/xtables
./configure            \
    --prefix=/usr      \
    --sbindir=/sbin    \
    --enable-libipq    \
    "${LIBNETFILTER}"  \
    "${LIBPCAP}"       \
    "${BPF_COMPILER}"  \
    "${NFTABLES}"      \
    --with-xtlibdir=/lib/xtables || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

# ссылка в /usr/bin iptables-xml -> ../../sbin/xtables-legacy-multi
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv ../../sbin/xtables-legacy-multi iptables-xml
)

# переносим библиотеки из /usr/lib в /lib и создаем ссылки на них в /usr/lib
(
    cd "${TMP_DIR}/usr/lib" || exit 1
    for FILE in ip4tc ip6tc ipq xtables; do
        mv -v "lib${FILE}.so."* ../../lib/
        ln -sfv "../../lib/$(readlink lib${FILE}.so)" lib${FILE}.so
    done
)

# установим скрипт /etc/rc.d/init.d/iptables для запуска фаервола при старте
# системы, который имеет 4 параметра:
#    start  - старт/рестарт iptables
#    status - вывод списка всех применяемых в настоящий момент правил
#    clear  - отключает все настроенные правила
#    lock   - блокировка передачи любых пакетов, кроме loopback (lo) интерфейса
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-iptables DESTDIR="${TMP_DIR}"
)

# основной скрипт запуска iptables /etc/rc.d/rc.iptables
RC_IPTABLES="/etc/rc.d/rc.iptables"
cat << EOF > "${TMP_DIR}${RC_IPTABLES}"
#!/bin/sh

# Begin ${RC_IPTABLES}

# insert connection-tracking modules (not needed if built into the kernel)
modprobe xt_LOG

# enable broadcast echo Protection
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# disable Source Routed Packets
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
echo 0 > /proc/sys/net/ipv4/conf/default/accept_source_route

# enable TCP SYN Cookie Protection
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# disable ICMP Redirect Acceptance
echo 0 > /proc/sys/net/ipv4/conf/default/accept_redirects

# do not send Redirect Messages
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects

# drop Spoofed Packets coming in on an interface, where responses
# would result in the reply going out a different interface.
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter

# log packets with impossible addresses.
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
echo 1 > /proc/sys/net/ipv4/conf/default/log_martians

# be verbose on dynamic ip-addresses  (not needed in case of static IP)
echo 2 > /proc/sys/net/ipv4/ip_dynaddr

# disable Explicit Congestion Notification
# too many routers are still ignorant
echo 0 > /proc/sys/net/ipv4/tcp_ecn

# set a known state
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

# these lines are here in case rules are already in place and the script is
# ever rerun on the fly. We want to remove all rules and pre-existing user
# defined chains before we implement new rules
iptables -F
iptables -X
iptables -Z

iptables -t nat -F

# allow local-only connections
iptables -A INPUT  -i lo -j ACCEPT

# free output on any interface to any ip for any service (equal to -P ACCEPT)
iptables -A OUTPUT -j ACCEPT

# permit answers on already established connections and permit new connections
# related to established ones (e.g. port mode ftp)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# log everything else. What's Windows' latest exploitable vulnerability?
iptables -A INPUT -j LOG --log-prefix "FIREWALL:INPUT "

# End ${RC_IPTABLES}
EOF

chmod 700 "${TMP_DIR}${RC_IPTABLES}"

if [ -f "${RC_IPTABLES}" ]; then
    mv "${RC_IPTABLES}" "${RC_IPTABLES}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${RC_IPTABLES}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (IP packet filter administration)
#
# Iptables is a packet filter administration tool. Iptables can be used to
# build internet firewalls based on stateless and stateful packet filtering,
# use NAT and masquerading for sharing internet access if you don't have enough
# public IP addresses, use NAT to implement transparent proxies, aid the tc and
# iproute2 systems used to build sophisticated QoS and policy routers, do
# further packet manipulation (mangling) like altering the TOS/DSCP/ECN bits of
# the IP header, and much more. See: http://www.netfilter.org
#
# Home page: https://netfilter.org/projects/${PRGNAME}/index.html
# Download:  http://www.netfilter.org/projects/${PRGNAME}/files/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
