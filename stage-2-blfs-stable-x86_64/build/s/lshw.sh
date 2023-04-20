#! /bin/bash

PRGNAME="lshw"

### lshw (Hardware Lister)
# инструмент для предоставления подробной информации об аппаратной конфигурации
# машины (память, процессор, материнская плата, прошивка, конфигурация кэша и
# т.д.)

# Required:    no
# Recommended: sqlite
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

GUI="no" # yes|no
ENABLE_SQLITE=0
[ -x /usr/lib/libsqlite3.so ] && ENABLE_SQLITE=1

VERSION="${VERSION}" make ZLIB=1 SQLITE="${ENABLE_SQLITE}" || exit 1
if [ "${GUI}" = "yes" ]; then
    VERSION="${VERSION}" make gui ZLIB=1 SQLITE="${ENABLE_SQLITE}" || exit 1
fi

VERSION="${VERSION}" \
    make ZLIB=1 SQLITE="${ENABLE_SQLITE}" install DESTDIR="${TMP_DIR}"

if [ "$GUI" = "yes" ]; then
    VERSION="${VERSION}" make \
        ZLIB=1 SQLITE="${ENABLE_SQLITE}" install-gui DESTDIR="${TMP_DIR}"
fi

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
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
