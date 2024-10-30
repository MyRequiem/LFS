#! /bin/bash

PRGNAME="hdparm"

### Hdparm (read/set hard drive parameters)
# Утилита предназначена для регулировки и просмотра параметров жёстких дисков с
# интерфейсом ATA. Утилита может установить такие параметры как объём
# кеш-памяти накопителя, спящий режим, управление питанием, управление
# акустикой и настройки DMA (Direct Memory Access).

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

make || exit 1
# пакет не содержит набота тестов
make binprefix=/usr install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (read/set hard drive parameters)
#
# hdparm provides a command line interface to various hard disk ioctls
# supported by the Linux ATA/IDE device driver subsystem. This may be required
# to enable higher-performing disk modes.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}/files/${PRGNAME}/
# Download:  https://downloads.sourceforge.net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
