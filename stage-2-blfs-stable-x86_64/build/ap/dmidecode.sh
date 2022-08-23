#! /bin/bash

PRGNAME="dmidecode"

### dmidecode (DMI table decoder)
# Инструмент для создания дампа содержимого DMI таблиц (SMBIOS) в удобочитаемом
# формате, которые содержат описание аппаратных компонентов системы, а также
# другую полезную информацию, такую как серийный номер и версия BIOS

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

DOC_DIR="/usr/share/doc/${PRGNAME}-${VERSION}"
make prefix=/usr docdir="${DOC_DIR}"                              || exit 1
make prefix=/usr docdir="${DOC_DIR}" install DESTDIR="${TMP_DIR}" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (DMI table decoder)
#
# dmidecode is a tool for dumping a computer's DMI table (some say SMBIOS)
# contents in a human-readable format. This table contains a description of the
# system's hardware components, as well as other useful pieces of information
# such as serial numbers and BIOS revision.
#
# Home page: https://www.nongnu.org/${PRGNAME}/
# Download:  http://download.savannah.gnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
