#! /bin/bash

PRGNAME="usbutils"

### usbutils (USB utilities)
# Утилиты, используемые для отображения информации о шинах USB в системе и
# подключенных к ним устройствах

# Required:    libusb
#              wget    (для скачивания файла данных usb.ids после сборки)
# Recommended: git
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
HWDATA="/usr/share/hwdata"
CRON_WEEKLY="/etc/cron.weekly"
mkdir -pv "${TMP_DIR}"{"${HWDATA}","${CRON_WEEKLY}"}

autoreconf -fiv && \
./configure        \
    --prefix=/usr  \
    --datadir=/usr/share/hwdata || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

# установим текущую версию файла данных /usr/share/hwdata/usb.ids
USB_IDS_URL="http://www.linux-usb.org/usb.ids"
wget "${USB_IDS_URL}" -O "${TMP_DIR}${HWDATA}/usb.ids"

# установим обновление файла usb.ids каждую неделю с помощью fcron
cat << EOF > "${TMP_DIR}${CRON_WEEKLY}/update-usbids.sh"
#!/bin/bash

/usr/bin/wget ${USB_IDS_URL} -O ${HWDATA}/usb.ids
EOF

chmod 754 "${TMP_DIR}${CRON_WEEKLY}/update-usbids.sh"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (USB utilities)
#
# The USB Utils package contains utilities used to display information about
# USB buses in the system and the devices connected to them.
#
# Home page: https://github.com/gregkh/${PRGNAME}
# Download:  https://github.com/gregkh/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
