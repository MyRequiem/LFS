#! /bin/bash

PRGNAME="alsa-firmware"

### ALSA Firmware (firmware for certain sound cards)
# Прошивки для определенных звуковых карт

# Required:    alsa-tools
# Recommended: no
# Optional:    as31 (для пересборки прошивок из исходников) https://www.pjrc.com/tech/8051/

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure \
    --prefix=/usr || exit 1

make || exit 1
# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (firmware for certain sound cards)
#
# The ALSA Firmware package contains firmware for certain sound cards
#
# Home page: https://www.alsa-project.org/
# Download:  https://www.alsa-project.org/files/pub/firmware/${PRGNAME}-${VERSION}.tar.bz2
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
