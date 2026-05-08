#! /bin/bash

PRGNAME="openvpn"

### OpenVPN (secure IP tunnel daemon)
# полнофункциональный SSL VPN с широким спектром конфигураций, включая
# удаленный доступ, site-to-site VPNs, Wi-Fi Security и т.д.

# Required:    lzo
#              net-tools
#              libcap-ng
#              libtirpc
#              mit-kerberos-v5
# Recommended: no
# Optional:    no

### KERNEL CONFIG
#    CONFIG_TUN=m|y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
RC_D="/etc/rc.d"
mkdir -pv "${TMP_DIR}"{${RC_D},/etc/${PRGNAME}}

# добавим группу nobody, если не существует
! grep -qE "^nobody:" /etc/group  && \
    groupadd -g 65534 nobody

./configure                        \
    --prefix=/usr                  \
    --sysconfdir="/etc/${PRGNAME}" \
    --localstatedir=/var           \
    --enable-lzo                   \
    --enable-iproute2              \
    --disable-plugin-auth-pam      \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

cp "${SOURCES}/rc.${PRGNAME}" "${TMP_DIR}${RC_D}"
chown root:root "${TMP_DIR}${RC_D}/rc.${PRGNAME}"
chmod 754 "${TMP_DIR}${RC_D}/rc.${PRGNAME}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (secure IP tunnel daemon)
#
# OpenVPN is a full-featured SSL VPN which can accommodate a wide range of
# configurations, including remote access, site-to-site VPNs, WiFi security,
# and enterprise-scale remote access with load balancing, failover, and
# fine-grained access-controls.
#
# Home page: https://${PRGNAME}.net
# Download:  https://github.com/OpenVPN/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
