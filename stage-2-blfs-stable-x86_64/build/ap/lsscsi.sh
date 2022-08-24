#! /bin/bash

PRGNAME="lsscsi"

### lsscsi (list SCSI devices or hosts, and their attributes)
# Вывод списка подключенных в данный момент scsi-устройств (на основе
# информации из sysfs)

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure           \
    --prefix=/usr     \
    --sysconfdir=/etc \
    --docdir="/usr/share/doc/${PRGNAME}-${VERSION}" || exit 1

make || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (list SCSI devices or hosts, and their attributes)
#
# Uses information in sysfs to list scsi devices (or hosts) currently attached
# to the system. Options can be used to control the amount and form of
# information provided for each device.
#
# Home page: http://sg.danny.cz/scsi/${PRGNAME}.html
# Download:  http://sg.danny.cz/scsi/${PRGNAME}-${VERSION}.tgz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
