#! /bin/bash

PRGNAME="wpa-supplicant"
ARCH_NAME="${PRGNAME//-/_}"

### WPA Supplicant (WPA/WPA2/IEEE 802.1X Supplicant)
# Клиент Wi-Fi Protected Access (WPA) и IEEE 802.1X supplicant. Применяется для
# подключения к защищенным паролем беспроводным точкам доступа.

# Required:    no
# Recommended: desktop-file-utils (для запуска update-desktop-database)
#              libnl
# Optional:    dbus    (для использвания с NetworkManager) см. DBUS ниже
#              libxml2 (для использвания с NetworkManager)
#              qt5     (для использвания с NetworkManager) см. QT5_GUI ниже

### Конфигурация ядра
#    CONFIG_NET=y
#    CONFIG_WIRELESS=y
#    CONFIG_CFG80211=m|y
#    CONFIG_CFG80211_WEXT=y
#    CONFIG_MAC80211=m|y
#    CONFIG_NETDEVICES=y
#    CONFIG_WLAN=y

# Конфигурация wpa_supplicant
# ----------------------------
# /etc/sysconfig/wpa_supplicant-wlan0.conf
#
# настроить подключение по названию точки доступа (SSID) и паролю
#    cat << EOF > /etc/sysconfig/wpa_supplicant-wlan0.conf
#    ctrl_interface=/run/wpa_supplicant
#    ctrl_interface_group=root
#    update_config=1
#    ap_scan=1
#    fast_reauth=1
#
#    EOF
#
#    # wpa_passphrase SSID SECRET_PASSWORD >> \
#           /etc/sysconfig/wpa_supplicant-wlan0.conf
#
# все параметры и их описание см. в исходниках
# wpa_supplicant/wpa_supplicant.conf
#
# подключиться к беспроводной точке доступа после настройки всех конфигов
#    # ifup wlan0

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/config_file_processing.sh"               || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}/usr/sbin"
mkdir -pv "${TMP_DIR}/etc"/{dbus-1/system.d,sysconfig}
mkdir -pv "${TMP_DIR}/usr/share"/{dbus-1/system-services,man/man{5,8}}

QT5_GUI="false"
DBUS="false"

cd "${ARCH_NAME}" || exit 1

# создадим файл конфигурации для сборки
# (см. описание опций в исходном коде wpa_supplicant/defconfig)
cat << EOF > .config
CONFIG_BACKEND=file
CONFIG_CTRL_IFACE=y
CONFIG_DEBUG_FILE=y
CONFIG_DEBUG_SYSLOG=y
CONFIG_DEBUG_SYSLOG_FACILITY=LOG_DAEMON
CONFIG_DRIVER_NL80211=y
CONFIG_DRIVER_WEXT=y
CONFIG_DRIVER_WIRED=y
CONFIG_EAP_GTC=y
CONFIG_EAP_LEAP=y
CONFIG_EAP_MD5=y
CONFIG_EAP_MSCHAPV2=y
CONFIG_EAP_OTP=y
CONFIG_EAP_PEAP=y
CONFIG_EAP_TLS=y
CONFIG_EAP_TTLS=y
CONFIG_IEEE8021X_EAPOL=y
CONFIG_IPV6=y
CONFIG_LIBNL32=y
CONFIG_PEERKEY=y
CONFIG_PKCS12=y
CONFIG_READLINE=y
CONFIG_SMARTCARD=y
CONFIG_WPS=y
CONFIG_DRIVER_NL80211_QCA=y
CONFIG_DRIVER_MACSEC_LINUX=y
CONFIG_EAP_FAST=y
CONFIG_EAP_PAX=y
CONFIG_EAP_AKA=y
CONFIG_EAP_SAKE=y
CONFIG_EAP_GPSK=y
CONFIG_EAP_GPSK_SHA256=y
CONFIG_EAP_TNC=y
CONFIG_EAP_IKEV2=y
CONFIG_MACSEC=y
CONFIG_SAE=y
CONFIG_SUITEB=y
CONFIG_SUITEB192=y
CONFIG_IEEE80211W=y
CONFIG_TLS=openssl
CONFIG_TLSV11=y
CONFIG_TLS_DEFAULT_CIPHERS="DEFAULT@SECLEVEL=1"
CONFIG_IEEE80211R=y
CONFIG_IEEE80211N=y
CONFIG_IEEE80211AC=y
CONFIG_AP=y
CONFIG_P2P=y
CONFIG_WIFI_DISPLAY=y
CONFIG_IBSS_RSN=y
CONFIG_BGSCAN_SIMPLE=y
CONFIG_DPP=y
CFLAGS += -I/usr/include/libnl3
EOF

if [ "${DBUS}" == "true" ]; then
    cat << EOF >> .config
CONFIG_CTRL_IFACE_DBUS=y
CONFIG_CTRL_IFACE_DBUS_NEW=y
CONFIG_CTRL_IFACE_DBUS_INTRO=y
EOF
fi

make BINDIR=/usr/sbin LIBDIR=/usr/lib

# если установлен Qt5 соберем графический интерфейс WPA Supplicant
# (имя каталога wpa_gui-qt4, но совместимо с Qt5)
if [ "${QT5_GUI}" == "true" ]; then
    if command -v qmake &>/dev/null; then
        pushd wpa_gui-qt4 || exit 1
        qmake wpa_gui.pro || exit 1
        make              || exit 1
        popd              || exit 1
    fi
fi

# пакет не имеет набора тестов

# в /usr/sbin/
#    wpa_cli
#    wpa_passphrase
#    wpa_supplicant
install -v -m755 wpa_{cli,passphrase,supplicant} "${TMP_DIR}/usr/sbin/"

# QT5_GUI
if [ -e wpa_gui-qt4/wpa_gui ]; then
    mkdir -p "${TMP_DIR}/usr/bin"
    install -v -m755 wpa_gui-qt4/wpa_gui   "${TMP_DIR}/usr/bin/"

    # man
    install -v -m644 doc/docbook/wpa_gui.8 "${TMP_DIR}/usr/share/man/man8/"

    # .desktop and pixmaps
    mkdir -p "${TMP_DIR}/usr/share"/{applications,pixmaps}
    install -v -m644 wpa_gui-qt4/wpa_gui.desktop \
        "${TMP_DIR}/usr/share/applications/"
    install -v -m644 wpa_gui-qt4/icons/wpa_gui.svg \
        "${TMP_DIR}/usr/share/pixmaps/"
fi

# файлы конфигурации D-Bus
install -v -m644 dbus/fi.w1.wpa_supplicant1.service \
    "${TMP_DIR}/usr/share/dbus-1/system-services/"
install -v -m644 dbus/dbus-wpa_supplicant.conf \
    "${TMP_DIR}/etc/dbus-1/system.d/wpa_supplicant.conf"

# man
install -v -m644 doc/docbook/wpa_supplicant.conf.5 \
    "${TMP_DIR}/usr/share/man/man5/"
install -v -m644 doc/docbook/wpa_{cli,passphrase,supplicant}.8 \
    "${TMP_DIR}/usr/share/man/man8/"

WPA_SUPPLICANT_WLAN0_CONF="/etc/sysconfig/wpa_supplicant-wlan0.conf"
cat << EOF > "${TMP_DIR}${WPA_SUPPLICANT_WLAN0_CONF}"
ctrl_interface=/run/wpa_supplicant
ctrl_interface_group=root
update_config=1
ap_scan=1
fast_reauth=1

EOF
chmod 600 "${TMP_DIR}${WPA_SUPPLICANT_WLAN0_CONF}"

IFCONFIG_WLAN0="/etc/sysconfig/ifconfig.wlan0"
cat << EOF > "${TMP_DIR}${IFCONFIG_WLAN0}"
# Begin ${IFCONFIG_WLAN0}

ONBOOT="yes"
IFACE="wlan0"

# The SERVICE variable defines the method used for obtaining the IP address.
# The LFS-Bootscripts package has a modular IP assignment format, and creating
# additional files in the /lib/services/ directory allows other IP assignment
# methods
SERVICE="wpa"

###
# additional arguments to wpa_supplicant
# main arguments are set in the script /lib/services/wpa
###
#    -q           decrease debugging verbosity
#    -B           run daemon in the background
#    -c filename  path to configuration file
#    -i           interface name
#    -D           driver
# WPA_ARGS="-q -B -c/etc/sysconfig/wpa_supplicant-wlan0.conf -iwlan0 -Dnl80211,wext"
WPA_ARGS=""

WPA_SERVICE="dhcpcd"
DHCP_START="--background --quiet --timeout 15 --ipv4only --hostname 192.168.1.1"
DHCP_STOP="--ipv4only -k wlan0"

# End ${IFCONFIG_WLAN0}
EOF

if [ -f "${WPA_SUPPLICANT_WLAN0_CONF}" ]; then
    mv "${WPA_SUPPLICANT_WLAN0_CONF}" "${WPA_SUPPLICANT_WLAN0_CONF}.old"
fi

if [ -f "${IFCONFIG_WLAN0}" ]; then
    mv "${IFCONFIG_WLAN0}" "${IFCONFIG_WLAN0}.old"
fi

# сервис /usr/lib/services/wpa
(
    cd "${ROOT}/blfs-bootscripts" || exit 1
    make install-service-wpa DESTDIR="${TMP_DIR}/usr"
)

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

config_file_processing "${WPA_SUPPLICANT_WLAN0_CONF}"
config_file_processing "${IFCONFIG_WLAN0}"

# обновим /usr/share/applications/mimeinfo.cache
if [ -e /usr/share/applications/wpa_gui.desktop ]; then
    command -v update-desktop-database &>/dev/null && \
        update-desktop-database -q
fi

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (WPA/WPA2/IEEE 802.1X Supplicant)
#
# WPA Supplicant is a Wi-Fi Protected Access (WPA) client and IEEE 802.1X
# supplicant. It implements WPA key negotiation with a WPA Authenticator and
# Extensible Authentication Protocol (EAP) authentication with an
# Authentication Server. In addition, it controls the roaming and IEEE 802.11
# authentication/association of the wireless LAN driver. This is useful for
# connecting to a password protected wireless access point.
#
# Home page: http://hostap.epitest.fi/${ARCH_NAME}/
# Download:  https://w1.fi/releases/${ARCH_NAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
