#! /bin/bash

PRGNAME="bluez"

### BlueZ (Bluetooth libraries and utilities)
# Стек протоколов Bluetooth, позволяющий использовать Bluetooth адаптеры и
# устройства. Пакет содержит Bluez библиотеки и утилиты.

# Required:    dbus
#              glib
#              libical
# Recommended: no
# Optional:    no

### Конфигурация ядра
#    CONFIG_NET=y
#    CONFIG_BT=y|m
#    CONFIG_BT_RFCOMM=y|m
#    CONFIG_BT_RFCOMM_TTY=y
#    CONFIG_BT_BNEP=y|m
#    CONFIG_BT_BNEP_MC_FILTER=y
#    CONFIG_BT_BNEP_PROTO_FILTER=y
#    CONFIG_BT_HIDP=y|m
#    CONFIG_RFKILL=y|m
#    CONFIG_CRYPTO=y
#    CONFIG_CRYPTO_USER_API_HASH=y|m
#    CONFIG_CRYPTO_USER_API_SKCIPHER=y|m
#
#    Networking support --->
#       Bluetooth subsystem support --->
#           Bluetooth device drivers --->
#               - выбираем подходящие драйверы для
#                 нашего оборудования Bluetooth

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1
source "${ROOT}/config_file_processing.sh"             || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
USR_SBIN="/usr/sbin"
ETC_BLUETOOTH="/etc/bluetooth"
DOC_PATH="/usr/share/doc/${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"{"${USR_SBIN}","${ETC_BLUETOOTH}","${DOC_PATH}"}

# исправим ошибку сегментации, возникающую при подключении к AD2P устройствам
# bluetooth
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-${VERSION}-upstream_fixes-1.patch" || exit 1

# создавать библиотеки совместимые с BlueZ v4, которые требуются для некоторых
# приложений
#    --enable-library
./configure              \
    --prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --enable-library     \
    --disable-systemd || exit 1

make || exit 1
# make check
make install DESTDIR="${TMP_DIR}"

# создам ссылку
#    /usr/sbin/bluetoothd -> ../libexec/bluetooth/bluetoothd
# для более удобного доступа к демону bluetooth
ln -svf ../libexec/bluetooth/bluetoothd "${TMP_DIR}${USR_SBIN}"

# документация
install -v -m644 doc/*.txt "${TMP_DIR}${DOC_PATH}"

### Конфигурация
#    /etc/bluetooth/main.conf
#    /etc/sysconfig/bluetooth (устанавливается из blfs-bootscripts ниже)
#    /etc/bluetooth/rfcomm.conf

MAIN_CONF="${ETC_BLUETOOTH}/main.conf"
install -v -m644 src/main.conf "${TMP_DIR}${MAIN_CONF}"

# установим загрузочный скрипт /etc/rc.d/init.d/bluetooth для запуска bluetooth
# демона при старте системы
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-bluetooth DESTDIR="${TMP_DIR}"
)

RFCOMM_CONF="${ETC_BLUETOOTH}/rfcomm.conf"
cat << EOF > "${TMP_DIR}${RFCOMM_CONF}"
# Start ${RFCOMM_CONF}

# Set up the RFCOMM configuration of the Bluetooth subsystem in the
# Linux kernel
# Use one line per command (see the rfcomm man page for options)

# End of ${RFCOMM_CONF}
EOF

UART_CONF="${ETC_BLUETOOTH}/uart.conf"
cat << EOF > "${TMP_DIR}${UART_CONF}"
# Start ${UART_CONF}

# Attach serial devices via UART HCI to BlueZ stack
# Use one line per device (see the hciattach man page for options)

# End of ${UART_CONF}
EOF

if [ -f "${MAIN_CONF}" ]; then
    mv "${MAIN_CONF}" "${MAIN_CONF}.old"
fi

if [ -f "${RFCOMM_CONF}" ]; then
    mv "${RFCOMM_CONF}" "${RFCOMM_CONF}.old"
fi

if [ -f "${UART_CONF}" ]; then
    mv "${UART_CONF}" "${UART_CONF}.old"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${MAIN_CONF}"
config_file_processing "${RFCOMM_CONF}"
config_file_processing "${UART_CONF}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Bluetooth libraries and utilities)
#
# Bluez is the Bluetooth protocol stack for Linux, allowing Bluetooth adaptors
# and devices to be used with Linux. This package contains the Bluez libraries,
# utilities, and other support files.
#
# Home page: http://www.${PRGNAME}.org
# Download:  https://www.kernel.org/pub/linux/bluetooth/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
