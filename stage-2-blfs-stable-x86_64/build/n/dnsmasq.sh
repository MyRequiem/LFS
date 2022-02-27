#! /bin/bash

PRGNAME="dnsmasq"

### dnsmasq (small DNS and DHCP server)
# Легковесный и быстроконфигурируемый DNS-, DHCP- и TFTP-сервер,
# предназначенный для обеспечения доменными именами и связанными с ними
# сервисами небольших сетей. Может обеспечивать именами локальные машины,
# которые не имеют глобальных DNS-записей. DHCP-сервер интегрирован с
# DNS-сервером и даёт машинам с IP-адресом доменное имя, сконфигурированное
# ранее в конфигурационном файле. Поддерживает привязку IP-адреса к компьютеру
# или автоматическую настройку IP-адресов из заданного диапазона и BOOTP для
# сетевой загрузки бездисковых машин.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
INIT_D="/etc/rc.d/init.d"
mkdir -pv "${TMP_DIR}${INIT_D}"

make \
    PREFIX=/usr || exit 1

make PREFIX=/usr install DESTDIR="${TMP_DIR}" || exit 1

DNSMASQ_CONF="/etc/${PRGNAME}.conf"
cat "${PRGNAME}.conf.example" > "${TMP_DIR}${DNSMASQ_CONF}"

RC_DNSMASQ="${INIT_D}/${PRGNAME}"
cat << EOF > "${TMP_DIR}${RC_DNSMASQ}"
#!/bin/sh

# start/stop/restart ${PRGNAME} (a small DNS/DHCP server)

# start ${PRGNAME}
${PRGNAME}_start() {
    if [ -x /usr/sbin/${PRGNAME} ]; then
        echo "Starting ${PRGNAME}: /usr/sbin/${PRGNAME}"
        /usr/sbin/${PRGNAME}
    fi
}

# stop ${PRGNAME}
${PRGNAME}_stop() {
    killall ${PRGNAME}
}

# restart ${PRGNAME}
${PRGNAME}_restart() {
    ${PRGNAME}_stop
    sleep 1
    ${PRGNAME}_start
}

case "\$1" in
    'start')
        ${PRGNAME}_start
        ;;
    'stop')
        ${PRGNAME}_stop
        ;;
    'restart')
        ${PRGNAME}_restart
        ;;
    *)
    echo "Usage ${INIT_D}/${PRGNAME}: start|stop|restart"
esac
EOF
chmod 754 "${TMP_DIR}${RC_DNSMASQ}"

if [ -f "${DNSMASQ_CONF}" ]; then
    mv "${DNSMASQ_CONF}" "${DNSMASQ_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${DNSMASQ_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (small DNS and DHCP server)
#
# Dnsmasq is a lightweight, easy to configure DNS forwarder and DHCP server. It
# is designed to provide DNS (and optionally DHCP) to a small network, and can
# serve the names of local machines which are not in the global DNS.
#
# Home page: https://thekelleys.org.uk/${PRGNAME}/doc.html
# Download:  https://thekelleys.org.uk/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
