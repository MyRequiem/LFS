#! /bin/bash

PRGNAME="xorg-evdev-driver"
ARCH_NAME="xf86-input-evdev"

### xorg-evdev-driver (Generic Linux input driver for the Xorg X server)
# Универсальный драйвер ввода для работы с клавиатурой, мышью, сенсорными
# панелями и устройствами Wacom.

# Required:    libevdev
#              mtdev
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
# Package: ${PRGNAME} (Generic Linux input driver for the Xorg X server)
#
# The Xorg Evdev Driver package contains a Generic Linux input driver for the
# Xorg X server. It handles keyboard, mouse, touchpads and wacom devices,
# though for touchpad and wacom advanced handling, additional drivers are
# required.
#
# Home page: http://www.x.org
# Download:  https://www.x.org/pub/individual/driver/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
