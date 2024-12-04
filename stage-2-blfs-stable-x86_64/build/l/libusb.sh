#! /bin/bash

PRGNAME="libusb"

### libusb (USB library)
# Библиотека, используемая некоторыми приложениями для доступа к USB
# устройствам.

# Required:    no
# Recommended: no
# Optional:    doxygen (для создания документации)

### Конфигурация ядра
#    CONFIG_USB_SUPPORT=y
#    CONFIG_USB=y|m
#    CONFIG_USB_PCI=y
#    CONFIG_USB_XHCI_HCD=y|m
#    CONFIG_USB_EHCI_HCD=y|m
#    CONFIG_USB_OHCI_HCD=y|m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (USB library)
#
# The libusb package contains a library used by some applications for USB
# device access.
#
# Home page: https://${PRGNAME}.info
# Download:  https://github.com/${PRGNAME}/${PRGNAME}/releases/download/v${VERSION}/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
