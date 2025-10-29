#! /bin/bash

PRGNAME="tunctl"

### tunctl (tool for controlling the TUN/TAP driver in Linux)
# tunctl используется для настройки и поддержки сетевых интерфейсов TUN/TAP,
# позволяя пользовательским приложениям имитировать сетевой трафик. Такие
# интерфейсы полезны для программного обеспечения VPN, виртуализации, эмуляции,
# моделирования и ряда других приложений.

# Required:    docbook-utils (для создания man-страницы)
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make BIN_DIR=/usr/sbin || exit 1
make install DESTDIR="${TMP_DIR}"

chmod 644 "${TMP_DIR}/usr/share/man/man8/${PRGNAME}.8"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (tool for controlling the TUN/TAP driver in Linux)
#
# tunctl is used to set up and maintain persistent TUN/TAP network interfaces,
# enabling user applications to simulate network traffic. Such interfaces is
# useful for VPN software, virtualization, emulation, simulation, and a number
# of other applications.
#
# Home page: https://${PRGNAME}.sourceforge.net/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
