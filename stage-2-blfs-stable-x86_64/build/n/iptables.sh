#! /bin/bash

PRGNAME="iptables"

### Iptables (IP packet filter administration)
# Классический встроенный инструмент для настройки сетевого защитного экрана в
# системе Linux. Он управляет правилами прохождения сетевых пакетов, защищая
# компьютер от внешних угроз и хакерских атак.

# Required:    --- для сборки xtables-nft-multi, требуется для libvirt ---
#              libmnl
#              libnftnl
# Recommended: no
# Optional:    libpcap                  (для сборки CLI утилиты конфигурации nfsynproxy)
#              bpf-utils                (для поддержки berkely packet filter) https://github.com/tadamdam/bpf-utils
#              libnfnetlink             (для поддержки connlabel) https://netfilter.org/projects/libnfnetlink/
#              libnetfilter-conntrack   (для поддержки connlabel) https://netfilter.org/projects/libnetfilter_conntrack/
#              nftables                 (для поддержки connlabel) https://netfilter.org/projects/nftables/

### Конфигурация ядра
# Брандмауэр в Linux управляется через интерфейс netfilter ядра Linux. Чтобы
# использовать iptables для настройки netfilter, необходимы следующие параметры
# конфигурации ядра:
#
#    CONFIG_NET=y
#    CONFIG_INET=y
#    CONFIG_NETFILTER=y
#    CONFIG_NETFILTER_ADVANCED=y
#    CONFIG_NETFILTER_NETLINK_QUEUE=m
#    CONFIG_NETFILTER_XTABLES=y|m
#    CONFIG_NETFILTER_XTABLES_LEGACY=y
#    CONFIG_NETFILTER_XT_TARGET_LOG=y|m
#    CONFIG_IP_NF_NAT=y|m
#    CONFIG_IP_NF_IPTABLES=y|m
#    CONFIG_IP_NF_IPTABLES_LEGACY=m
#    CONFIG_IP_NF_FILTER=m
#    CONFIG_IP_NF_TARGET_REJECT=m
#    CONFIG_NF_TABLES=m
#    CONFIG_NF_TABLES_INET=y
#    CONFIG_NF_TABLES_IPV4=y
#    CONFIG_NF_CONNTRACK=y|m
#    CONFIG_NFT_NAT=m
#    CONFIG_NFT_MASQ=m
#    CONFIG_NFT_COMPAT=m
#    CONFIG_NFT_NUMGEN=m
#    CONFIG_NFT_CT=m
#    CONFIG_NFT_CONNLIMIT=m
#    CONFIG_NFT_LOG=m
#    CONFIG_NFT_LIMIT=m
#    CONFIG_NFT_TUNNEL=m
#    CONFIG_NFT_QUOTA=m
#    CONFIG_NFT_REJECT=m
#    CONFIG_NFT_REJECT_IPV4=m
#    CONFIG_NFT_QUEUE=m
###
# NOTE:
#    При обновлении ядра Linux пакет необходимо пересобрать.
###

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# Собирать библиотеку libipq.so, которая используется некоторыми пакетами за
# пределами BLFS
#    --enable-libipq
./configure              \
    --prefix=/usr        \
    --sbindir=/usr/sbin  \
    --enable-nftables    \
    --enable-libipq      \
    --disable-nfsynproxy \
    --disable-bpf-compiler || exit 1

make || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

###
# Утилита xtables-legacy-multi
###
# Linux 5.x - 6.16.x  - была объявлена устаревшей (Deprecated)
# Linux >=6.17.x      - по привычке шлет ядру старые системные вызовы, а ядро
#                           их физически больше не поддерживает (по умолчанию)
###
# ПЕРЕКЛЮЧЕНИЕ НА СОВРЕМЕННЫЙ NFT-БЭКЕНД
###
# Начиная с Linux 6.17.x классический legacy-код файрвола по умолчанию отключен.
# Параметр CONFIG_IP_NF_IPTABLES=m теперь является "обманкой"
# (shim-прослойкой) внутри модуля nf_tables.ko - физический файл ip_tables.ko
# больше НЕ создается (по умолчанию):
#
# CONFIG_IP_NF_IPTABLES=m
#    $ find /lib/modules/ -type f -name "*table*"
#    /lib/modules/6.18.16/kernel/net/netfilter/x_tables.ko
#    /lib/modules/6.18.16/kernel/net/netfilter/nf_tables.ko
#
#    ####
#    HO, если установлено:
#       CONFIG_NETFILTER_XTABLES_LEGACY=y
#       CONFIG_IP_NF_IPTABLES_LEGACY=m
#    то ip_tables.ko собирается:
#       $ find /lib/modules/ -type f -name "*table*"
#           /lib/modules/6.18.16/kernel/net/netfilter/x_tables.ko
#           /lib/modules/6.18.16/kernel/net/netfilter/nf_tables.ko
#           /lib/modules/6.18.16/kernel/net/ipv4/netfilter/ip_tables.ko
#           /lib/modules/6.18.16/kernel/net/ipv4/netfilter/iptable_mangle.ko
#           /lib/modules/6.18.16/kernel/net/ipv4/netfilter/iptable_filter.ko
#           /lib/modules/6.18.16/kernel/net/ipv4/netfilter/iptable_nat.ko
#    Если разработчики ядра не просто объявили ip_tables.ko как Deprecated, но
#    и спрятали в конфиге, то скоро этот код будет вообще вырезан, поэтому
#    лучше сразу перейдем на NFT
#    ####
#
# По умолчанию сборка iptables создает ссылки на legacy:
#    iptables         -> xtables-legacy-multi
#    iptables-save    -> xtables-legacy-multi
#    iptables-restore -> xtables-legacy-multi
# Принудительно перенаправляем их на xtables-nft-multi для прозрачной
# трансляции правил:
ln -sf xtables-nft-multi "${TMP_DIR}/usr/sbin/iptables"
ln -sf xtables-nft-multi "${TMP_DIR}/usr/sbin/iptables-save"
ln -sf xtables-nft-multi "${TMP_DIR}/usr/sbin/iptables-restore"
# Не забываем про IPv6, если собран:
if [ -e "${TMP_DIR}/usr/sbin/ip6tables" ]; then
    ln -sf xtables-nft-multi "${TMP_DIR}/usr/sbin/ip6tables"
    ln -sf xtables-nft-multi "${TMP_DIR}/usr/sbin/ip6tables-save"
    ln -sf xtables-nft-multi "${TMP_DIR}/usr/sbin/ip6tables-restore"
fi

# Скрипт /etc/rc.d/init.d/iptables для запуска iptables при старте системы
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-iptables DESTDIR="${TMP_DIR}"
)

# Основной скрипт запуска iptables /etc/rc.d/rc.iptables, который запускается
# при старте системы из скрипта /etc/rc.d/init.d/iptables
RC_IPTABLES="/etc/rc.d/rc.iptables"
cat << EOF > "${TMP_DIR}${RC_IPTABLES}"
#!/bin/sh

# Begin ${RC_IPTABLES}

# Insert connection-tracking modules (not needed if built into the kernel)
modprobe nf_conntrack
modprobe xt_LOG

# Enable broadcast echo Protection
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Disable Source Routed Packets
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
echo 0 > /proc/sys/net/ipv4/conf/default/accept_source_route

# Enable TCP SYN Cookie Protection
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Disable ICMP Redirect Acceptance
echo 0 > /proc/sys/net/ipv4/conf/default/accept_redirects

# Do not send Redirect Messages
echo 0 > /proc/sys/net/ipv4/conf/all/send_redirects
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects

# Drop Spoofed Packets coming in on an interface, where responses would result
# in the reply going out a different interface.
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter

# Log packets with impossible addresses.
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians
echo 1 > /proc/sys/net/ipv4/conf/default/log_martians

# be verbose on dynamic ip-addresses  (not needed in case of static IP)
echo 2 > /proc/sys/net/ipv4/ip_dynaddr

# disable Explicit Congestion Notification too many routers are still ignorant
echo 0 > /proc/sys/net/ipv4/tcp_ecn

# Set a known state
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

# These lines are here in case rules are already in place and the script is
# ever rerun on the fly. We want to remove all rules and pre-existing user
# defined chains before we implement new rules.
iptables -F
iptables -X
iptables -Z

iptables -t nat -F

# Allow local-only connections
iptables -A INPUT  -i lo -j ACCEPT

# Free output on any interface to any ip for any service (equal to -P ACCEPT)
iptables -A OUTPUT -j ACCEPT

# Permit answers on already established connections and permit new connections
# related to established ones (e.g. port mode ftp)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Drop any incoming MULTICAST or BROADCAST packet before logging: The box
# outputs several of them when using netbios or mDNS, and those appear
# immediately as incoming, which clutters the log.
iptables -A INPUT -m addrtype --dst-type BROADCAST,MULTICAST -j DROP

# Log everything else.
iptables -A INPUT -j LOG --log-prefix "FIREWALL:INPUT "

# End ${RC_IPTABLES}
EOF

if [ -f "${RC_IPTABLES}" ]; then
    mv "${RC_IPTABLES}" "${RC_IPTABLES}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${RC_IPTABLES}"

chmod 700 "${RC_IPTABLES}"

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
# Download:  https://www.netfilter.org/projects/${PRGNAME}/files/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
