#! /bin/bash

PRGNAME="xorg-libinput-driver"
ARCH_NAME="xf86-input-libinput"

### Xorg Libinput Driver (Xorg X11 libinput input driver)
# Универсальный драйвер ввода для X на основе libinput. Служит оболочкой,
# необходимой libinput для общения с X. Может использоваться как замена для
# evdev и synaptics. Поддерживает мышь, клавиатуру, тачпад, сенсорный экран и
# планшеты.

# Required:    libinput
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
# make check
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Xorg X11 libinput input driver)
#
# A generic input driver for the X.Org X11 X server based on libinput,
# supporting all devices (mouse, keyboard, touchpad, touchscreen, and tablet
# devices). Serves as a wrapper needed by libinput to communicate with X.Org.
# This driver can be used as as drop-in replacement for evdev and synaptics.
#
# Home page: https://cgit.freedesktop.org/xorg/driver/${ARCH_NAME}/
# Download:  https://www.x.org/pub/individual/driver/${ARCH_NAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
