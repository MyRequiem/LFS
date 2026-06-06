#! /bin/bash

PRGNAME="dnsmasq"

### dnsmasq (small DNS and DHCP server)
# Легковесный сетевой сервер, который раздает интернет-адреса устройствам в
# сети и переводит понятные имена сайтов в IP-адреса. Он идеально подходит для
# домашних роутеров и виртуальных сетей.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/etc"

make PREFIX=/usr                              || exit 1
make PREFIX=/usr install DESTDIR="${TMP_DIR}" || exit 1

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help,licenses}

DNSMASQ_CONF="/etc/${PRGNAME}.conf"
cat "${PRGNAME}.conf.example" > "${TMP_DIR}${DNSMASQ_CONF}" || exit 1

if [ -f "${DNSMASQ_CONF}" ]; then
    mv "${DNSMASQ_CONF}" "${DNSMASQ_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
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
