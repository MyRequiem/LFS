#! /bin/bash

PRGNAME="dhcpcd"

### dhcpcd (DHCP client daemon)
# DHCP client daemon на этапе конфигурации сетевого устройства обращается к
# серверу DHCP и получает от него нужные параметры

# Required:    no
# Recommended: no
# Optional:    llvm
#              ntp
#              chronyd (https://chrony.tuxfamily.org/)
#              ypbind  (https://github.com/thkukuk/ypbind-mt/)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# добавим группу dhcpcd, если не существует
! grep -qE "^dhcpcd:" /etc/group  && \
    groupadd -g 52 dhcpcd

# добавим пользователя dhcpcd, если не существует
VAR_LIB_DHCPCD="/var/lib/dhcpcd"
! grep -qE "^dhcpcd:" /etc/passwd && \
    useradd -c 'dhcpcd PrivSep'  \
            -d ${VAR_LIB_DHCPCD} \
            -g dhcpcd            \
            -s /bin/false        \
            -u 52 dhcpcd

# по умолчанию /var/db не соответствует FHS
#    --dbdir=/var/lib/dhcpcd
# /libexec по умолчанию не совместим с FHS, но так как этот каталог должен быть
# доступен в начале загрузки, /usr/libexec также нельзя использовать
#    --libexecdir=/lib/dhcpcd
./configure                 \
    --prefix=/usr           \
    --sysconfdir=/etc       \
    --privsepuser=dhcpcd    \
    --dbdir=/var/lib/dhcpcd \
    --libexecdir=/lib/dhcpcd || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

# install network service script: /lib/services/dhcpcd
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-service-dhcpcd DESTDIR="${TMP_DIR}"
)

# исправим скрипт запуска сервиса
#    pidfile_old="/var/run/dhcpcd-$1.pid"
#    ->
#    pidfile_old="/var/run/dhcpcd/$1.pid"
sed -i "s;/run/dhcpcd-;/run/dhcpcd/;g" "${TMP_DIR}/lib/services/dhcpcd"

ETC_SYSCONFIG="/etc/sysconfig"
mkdir -p "${TMP_DIR}${ETC_SYSCONFIG}"
cat << EOF > "${TMP_DIR}${ETC_SYSCONFIG}/ifconfig.eth0.dhcp.example"
ONBOOT="yes"
IFACE="eth0"
SERVICE="dhcpcd"
# DHCP_START=" <insert appropriate start options here>"
DHCP_START="-b -q -t 10 -h 192.168.1.1"
DHCP_STOP="-k <insert additional stop options here>"
EOF

DHCPCD_CONF="/etc/dhcpcd.conf"
if [ -f "${DHCPCD_CONF}" ]; then
    mv "${DHCPCD_CONF}" "${DHCPCD_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${DHCPCD_CONF}"

chmod 700           "${VAR_LIB_DHCPCD}"
chown dhcpcd:dhcpcd "${VAR_LIB_DHCPCD}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (DHCP client daemon)
#
# dhcpcd is an implementation of the DHCP client specified in RFC2131. A DHCP
# client is useful for connecting your computer to a network which uses DHCP to
# assign network addresses. dhcpcd strives to be a fully featured, yet very
# lightweight DHCP client.
#
# Home page: https://roy.marples.name/projects/${PRGNAME}/
# Download:  https://roy.marples.name/downloads/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
