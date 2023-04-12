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
VAR_LIB_DHCPCD="/var/lib/dhcpcd"
mkdir -pv "${TMP_DIR}${VAR_LIB_DHCPCD}"

# директория /var/lib/dhcpcd должна присутствовать в системе
if ! [ -d "${VAR_LIB_DHCPCD}" ]; then
    install -v -m700 -d      "${VAR_LIB_DHCPCD}"
    chown   -v dhcpcd:dhcpcd "${VAR_LIB_DHCPCD}"
fi

# добавим группу dhcpcd, если не существует
! grep -qE "^dhcpcd:" /etc/group  && \
    groupadd -g 52 dhcpcd

# добавим пользователя dhcpcd, если не существует
! grep -qE "^dhcpcd:" /etc/passwd && \
    useradd -c 'dhcpcd PrivSep'      \
            -d ${VAR_LIB_DHCPCD}     \
            -g dhcpcd                \
            -s /bin/false            \
            -u 52 dhcpcd

# исправим runtime error, вызванную изменениями в glibc-2.36
sed '/Deny everything else/i SECCOMP_ALLOW(__NR_getrandom),' \
    -i src/privsep-linux.c

# по умолчанию /var/db не соответствует FHS
#    --dbdir=/var/lib/dhcpcd
./configure                      \
    --prefix=/usr                \
    --sysconfdir=/etc            \
    --libexecdir=/usr/lib/dhcpcd \
    --dbdir="${VAR_LIB_DHCPCD}"  \
    --runstatedir=/run           \
    --disable-privsep || exit 1

make || exit 1
# make test
make install DESTDIR="${TMP_DIR}"

# install network service script: /usr/lib/services/dhcpcd
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    # по умолчанию устанавливается в /lib/services/, нам нужно в
    # /usr/lib/services/
    make install-service-dhcpcd DESTDIR="${TMP_DIR}/usr"
)

# исправим скрипт запуска сервиса:
#    pidfile_old="/run/dhcpcd-$1.pid"
#    ->
#    pidfile_old="/run/dhcpcd/$1.pid"
sed -i "s;/run/dhcpcd-;/run/dhcpcd/;g" "${TMP_DIR}/usr/lib/services/dhcpcd"

# файл конфигурации запуска Ethernet интерфейса /etc/sysconfig/ifconfig.eth0,
# устанавливаемый в LFS вместе с пакетом network-configuration, уже содержит
# инструкции для настройки для DHCP

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
