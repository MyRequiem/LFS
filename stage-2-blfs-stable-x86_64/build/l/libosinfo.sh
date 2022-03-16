#! /bin/bash

PRGNAME="libosinfo"

### libosinfo (operating systems library)
# API библиотеки на основе GObject для управления информацией об операционных
# системах, гипервизорами и виртуальными аппаратными устройствами, которые они
# могут поддерживать. Включает в себя базу данных, содержащую метаданные
# устройств и предоставляет API для сопоставления/идентификации оптимальных
# устройств для развертывания операционной системы на гипервизоре.

# Required:    glib
#              sinfo-db-tools
#              osinfo-db
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

PCI_IDS="/usr/share/hwdata/pci.ids.gz"
USB_IDS="/usr/share/hwdata/usb.ids"

mkdir build
cd build || exit 1

meson                                \
    --prefix=/usr                    \
    --sysconfdir=/etc                \
    --localstatedir=/var             \
    --buildtype=release              \
    -Denable-gtk-doc=false           \
    -Dwith-pci-ids-path="${PCI_IDS}" \
    -Dwith-usb-ids-path="${USB_IDS}" \
    .. || exit 1

ninja || exit 1
DESTDIR="${TMP_DIR}" ninja install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (operating systems library)
#
# GObject based library API for managing information about operating systems,
# hypervisors and the (virtual) hardware devices they can support. It includes
# a database containing device metadata and provides APIs to match/identify
# optimal devices for deploying an operating system on a hypervisor.
#
# Home page: https://${PRGNAME}.org/
# Download:  https://releases.pagure.org/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
