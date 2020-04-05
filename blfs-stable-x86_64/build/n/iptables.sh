#! /bin/bash

PRGNAME="iptables"

### Iptables
# Стандартный интерфейс управления работой межсетевого экрана (брандмауэра)
# netfilter ядра linux. Конфигурация ядра:
#    CONFIG_NET=y
#    CONFIG_NETFILTER=y
#
# Note:
#    При обновлении ядра linux пакет необходимо пересобирать.

# http://www.linuxfromscratch.org/blfs/view/9.0/postlfs/iptables.html

# Home page: https://netfilter.org/projects/iptables/index.html
# Download:  http://www.netfilter.org/projects/iptables/files/iptables-1.8.3.tar.bz2

# Required: no
# Optional: nftables (http://www.netfilter.org/projects/nftables/index.html)

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}config_file_processing.sh"             || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"/{usr/bin,lib}

# отключаем сборку nftables compat, т.к. опциональная зависимость nftables не
# установлена в системе
#    --disable-nftables
# собирать библиотеку libipq.so
#    --enable-libipq
# все модули iptables установливаются в /lib/xtables
#    --with-xtlibdir=/lib/xtables
./configure \
    --prefix=/usr      \
    --sbindir=/sbin    \
    --disable-nftables \
    --enable-libipq    \
    --with-xtlibdir=/lib/xtables || exit 1

make || exit 1
# пакет не содержит набора тестов
make install
make install DESTDIR="${TMP_DIR}"

ln -sfv ../../sbin/xtables-legacy-multi /usr/bin/iptables-xml
(
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -sfv ../../sbin/xtables-legacy-multi iptables-xml
)

for FILE in ip4tc ip6tc ipq iptc xtables; do
    mv -v /usr/lib/lib${FILE}.so.* /lib
    ln -sfv "../../lib/$(readlink /usr/lib/lib${FILE}.so)" \
        "/usr/lib/lib${FILE}.so"
done

(
    cd "${TMP_DIR}/usr/lib" || exit 1
    for FILE in ip4tc ip6tc ipq iptc xtables; do
        mv -v "lib${FILE}.so."* ../../lib/
        ln -sfv "../../lib/$(readlink lib${FILE}.so)" lib${FILE}.so
    done
)

# установим скрипт /etc/rc.d/init.d/iptables для запуска фаервола при старте
# системы
IPTABLES="/etc/rc.d/init.d/iptables"
if [ -f "${IPTABLES}" ]; then
    mv "${IPTABLES}" "${IPTABLES}.old"
fi

(
    cd /root/blfs-bootscripts || exit 1
    make install-iptables
    make install-iptables DESTDIR="${TMP_DIR}"
)

config_file_processing "${IPTABLES}"

# Скрипт управления iptables имеет 4 параметра:
# /etc/rc.d/init.d/iptables start  - старт/рестарт iptables
# /etc/rc.d/init.d/iptables status - вывод списка всех применяемых в настоящий
#                                       момент правил
# /etc/rc.d/init.d/iptables clear  - отключает все настроенные правила
# /etc/rc.d/init.d/iptables lock   - блокировка передачи любых пакетов, кроме
#                                       loopback (lo) интерфейса

# Основной скрипт запуска iptables /etc/rc.d/rc.iptables
RC_IPTABLES="/etc/rc.d/rc.iptables"
if [ -f "${RC_IPTABLES}" ]; then
    mv "${RC_IPTABLES}" "${RC_IPTABLES}.old"
fi

cat << EOF > "${RC_IPTABLES}"
#!/bin/sh

# Begin ${RC_IPTABLES}

# Insert iptables modules (not needed if built into the kernel)
# modprobe nf_conntrack
# modprobe nf_conntrack_ftp
# modprobe xt_conntrack
modprobe xt_LOG
# modprobe xt_state

# Enable broadcast echo Protection
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts

# Disable Source Routed Packets
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route

# Enable TCP SYN Cookie Protection
echo 1 > /proc/sys/net/ipv4/tcp_syncookies

# Disable ICMP Redirect Acceptance
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects

# Don't send Redirect Messages
echo 0 > /proc/sys/net/ipv4/conf/default/send_redirects

# Drop Spoofed Packets coming in on an interface where responses
# would result in the reply going out a different interface.
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter

# Log packets with impossible addresses.
echo 1 > /proc/sys/net/ipv4/conf/all/log_martians

# Be verbose on dynamic ip-addresses  (not needed in case of static IP)
echo 2 > /proc/sys/net/ipv4/ip_dynaddr

# Disable Explicit Congestion Notification
# Too many routers are still ignorant
echo 0 > /proc/sys/net/ipv4/tcp_ecn

# Set a known state
iptables -P INPUT   DROP
iptables -P FORWARD DROP
iptables -P OUTPUT  DROP

# These lines are here in case rules are already in place and the
# script is ever rerun on the fly. We want to remove all rules and
# pre-existing user defined chains before we implement new rules.
iptables -F
iptables -X
iptables -Z

iptables -t nat -F

# Allow local connections
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow forwarding if the initiated on the intranet
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD ! -i eth0 -m conntrack --ctstate NEW       -j ACCEPT

# Do masquerading
# (not needed if intranet is not using private ip-addresses)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Log everything for debugging
# (last of all rules, but before policy rules)
iptables -A INPUT   -j LOG --log-prefix "FIREWALL:INPUT "
iptables -A FORWARD -j LOG --log-prefix "FIREWALL:FORWARD "
iptables -A OUTPUT  -j LOG --log-prefix "FIREWALL:OUTPUT "

# Enable IP Forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# End ${RC_IPTABLES}
EOF

config_file_processing "${RC_IPTABLES}"
cp "${RC_IPTABLES}" "${TMP_DIR}/etc/rc.d/"
chmod 744 "${RC_IPTABLES}"
chmod 744 "${TMP_DIR}${RC_IPTABLES}"

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
