#! /bin/bash

PRGNAME="sg3-utils"
ARCH_NAME="sg3_utils"

### sg3-utils (utilities and test programs for the linux sg driver)
# Утилиты низкого уровня для устройств, которые используют SCSI набор команд.
# Помимо устройств параллельного интерфейса SCSI (SPI), набор команд SCSI
# используется устройствами ATAPI (CD/DVD и tapes), USB устройствами хранения
# данных, дисками Fibre Channel, устройствами хранения данных IEEE 1394
# (которые используют протокол SBP), устройствами SAS, iSCSI и FCoE.

# http://www.linuxfromscratch.org/blfs/view/stable/general/sg3_utils.html

# Home page: http://sg.danny.cz/sg/sg3_utils.html
# Download:  http://sg.danny.cz/sg/p/sg3_utils-1.44.tar.xz

# Required: no
# Optional: no

ROOT="/root"
source "${ROOT}/check_environment.sh"                    || exit 1
source "${ROOT}/unpack_source_archive.sh" "${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-static || exit 1

make || exit 1
# пакет не имеет набора тестов
make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (utilities and test programs for the linux sg driver)
#
# This package contains low level utilities for devices that use a SCSI command
# set. Apart from SCSI parallel interface (SPI) devices, the SCSI command set
# is used by ATAPI devices (CD/DVDs and tapes), USB mass storage devices, Fibre
# Channel disks, IEEE 1394 storage devices (that use the "SBP" protocol), SAS,
# iSCSI and FCoE devices (among others).
#
# Home page: http://sg.danny.cz/sg/${ARCH_NAME}.html
# Download:  http://sg.danny.cz/sg/p/${ARCH_NAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"

echo -e "\n---------------\nRemoving *.la files..."
remove-la-files.sh
echo "---------------"
