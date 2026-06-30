#! /bin/bash

PRGNAME="lshw"

### lshw (Hardware Lister)
# Утилита, выдающая максимально детальный отчет обо всем «железе» компьютера в
# одном списке.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

VERSION="${VERSION}" make ZLIB=1 SQLITE=1 || exit 1
VERSION="${VERSION}" make ZLIB=1 SQLITE=1 install DESTDIR="${TMP_DIR}"

rm -rf "${TMP_DIR}/usr/share"/{doc,gtk-doc,help}

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
source "${ROOT}/clean-locales.sh"  || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (Hardware Lister)
#
# lshw (Hardware Lister) is a small tool to provide detailed information on the
# hardware configuration of the machine. It can report exact memory
# configuration, firmware version, mainboard configuration, CPU version and
# speed, cache configuration, bus speed, etc. on DMI-capable x86 or EFI (IA-64)
# systems and on some PowerPC machines (PowerMac G4 is known to work).
#
# Home page: https://ezix.org/project/wiki/HardwareLiSter
# Download:  https://www.ezix.org/software/files/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
