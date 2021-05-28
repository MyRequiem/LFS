#! /bin/bash

PRGNAME="xorg-synaptics-driver"
ARCH_NAME="xf86-input-synaptics"

### Xorg Synaptics Driver (Synaptics touchpad driver for X.Org)
# Драйвер ввода X.Org для поддержки сенсорных панелей Synaptics (тачпадов).
# Хотя драйвер evdev хорошо справляется с сенсорными панелями, этот драйвер
# необходим, если мы хотим использовать расширенные функции, такие как
# многократное нажатие, прокрутка с помощью тачпада, выключать тачпад при
# наборе текста и т. д.

# Required:    libevdev
#              xorg-server
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1
source "${ROOT}/xorg_config.sh"                          || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# shellcheck disable=SC2086
./configure \
    ${XORG_CONFIG} || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Synaptics touchpad driver for X.Org)
#
# The Xorg Synaptics Driver package contains the X.Org Input Driver, support
# programs and SDK for Synaptics touchpads. Even though the evdev driver can
# handle touchpads very well, this driver is required if you want to use
# advanced features like multi tapping, scrolling with touchpad, turning the
# touchpad off while typing, etc.
#
# Home page: https://www.x.org/pub/individual/driver/
# Download:  https://www.x.org/pub/individual/driver/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
