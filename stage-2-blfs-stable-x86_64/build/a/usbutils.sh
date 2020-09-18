#! /bin/bash

PRGNAME="usbutils"

### usbutils (USB utilities)
# Утилиты, используемые для отображения информации о шинах USB в системе и
# подключенных к ним устройствах

# http://www.linuxfromscratch.org/blfs/view/stable/general/usbutils.html

# Home page: https://github.com/gregkh/usbutils
# Download:  https://www.kernel.org/pub/linux/utils/usb/usbutils/usbutils-012.tar.xz

# Required: libusb
#           wget    (для скачивания файла данных usb.ids после сборки)
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
HWDATA="/usr/share/hwdata"
CRON_WEEKLY="/etc/cron.weekly"
mkdir -pv "${TMP_DIR}"{"${HWDATA}","${CRON_WEEKLY}"}

./autogen.sh      \
    --prefix=/usr \
    --datadir=/usr/share/hwdata || exit 1

make || exit 1
# пакет не имеет набора тестов
make install
make install DESTDIR="${TMP_DIR}"

# установим текущую версию файла данных /usr/share/hwdata/usb.ids
USB_IDS_URL="http://www.linux-usb.org/usb.ids"
install -d -m755 "${HWDATA}"
rm -f "${HWDATA}/usb.ids"
wget "${USB_IDS_URL}" -O "${HWDATA}/usb.ids"
cp "${HWDATA}/usb.ids" "${TMP_DIR}${HWDATA}/"

# установим обновление файла usb.ids каждую неделю с помощью fcron
install -d -m755 "${CRON_WEEKLY}"
cat << EOF > "${CRON_WEEKLY}/update-usbids.sh"
#!/bin/bash

/usr/bin/wget ${USB_IDS_URL} -O ${HWDATA}/usb.ids
EOF

chmod 754 "${CRON_WEEKLY}/update-usbids.sh"
cp "${CRON_WEEKLY}/update-usbids.sh" "${TMP_DIR}${CRON_WEEKLY}/"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (USB utilities)
#
# The USB Utils package contains utilities used to display information about
# USB buses in the system and the devices connected to them.
#
# Home page: https://github.com/gregkh/${PRGNAME}
# Download:  https://www.kernel.org/pub/linux/utils/usb/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
