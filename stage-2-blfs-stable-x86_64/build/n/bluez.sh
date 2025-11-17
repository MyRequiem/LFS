#! /bin/bash

PRGNAME="bluez"

### BlueZ (Bluetooth libraries and utilities)
# Стек протоколов Bluetooth для Linux

# Required:    dbus
#              glib
#              libical
# Recommended: no
# Optional:    python3-docutils

### Конфигурация ядра
#    EXPERT=y
#    TIMERFD=y
#    EVENTFD=y
#    NET=y
#    BT=y|m
#    BT_BREDR=y
#    BT_RFCOMM=y|m
#    BT_RFCOMM_TTY=y
#    BT_BNEP=y|m
#    BT_BNEP_MC_FILTER=y
#    BT_BNEP_PROTO_FILTER=y
#    BT_HIDP=y|m
#    BT_HCIBTUSB=y|m
#    BT_HCIBTSDIO=y|m
#    BT_HCIUART=y|m
#    RFKILL=y|m
#    CRYPTO=y
#    CRYPTO_USER=y|m
#    CRYPTO_AES=y|m
#    CRYPTO_CMAC=y|m
#    CRYPTO_USER_API_HASH=y|m
#    CRYPTO_USER_API_SKCIPHER=y|m
#    CRYPTO_USER_API_AEAD=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/sbin"

./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --enable-library     \
    --enable-manpages    \
    --disable-systemd || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# /usr/sbin/bluetoothd -> ../libexec/bluetooth/bluetoothd
ln -svf ../libexec/bluetooth/bluetoothd "${TMP_DIR}/usr/sbin/"

install -v -dm755 "${TMP_DIR}/etc/bluetooth"
install -v -m644 src/main.conf "${TMP_DIR}/etc/bluetooth/main.conf"

SERVICES="/usr/share/dbus-1/services"
mkdir -p "${TMP_DIR}${SERVICES}"
install -m644 ./obexd/src/org.bluez.obex.service "${TMP_DIR}${SERVICES}"

RFCOMM_CONF="/etc/bluetooth/rfcomm.conf"
cat << EOF > "${TMP_DIR}${RFCOMM_CONF}"
# Start ${RFCOMM_CONF}
# Set up the RFCOMM configuration of the Bluetooth subsystem in the Linux kernel.
# Use one line per command
# See the rfcomm man page for options

# End of ${RFCOMM_CONF}
EOF

UART_CONF="/etc/bluetooth/uart.conf"
cat << EOF > "${TMP_DIR}${UART_CONF}"
# Start ${UART_CONF}
# Attach serial devices via UART HCI to BlueZ stack
# Use one line per device
# See the hciattach man page for options

# End of ${UART_CONF}
EOF

(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-bluetooth DESTDIR="${TMP_DIR}"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Bluetooth libraries and utilities)
#
# The BlueZ package contains the Bluetooth protocol stack for Linux
#
# Home page: https://www.${PRGNAME}.org/
# Download:  https://www.kernel.org/pub/linux/bluetooth/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
