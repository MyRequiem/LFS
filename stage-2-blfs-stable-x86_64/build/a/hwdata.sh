#! /bin/bash

PRGNAME="hwdata"

### hwdata (hardware identification and configuration data)
# пакет содержит различные данные идентификации и конфигурации оборудования,
# такие как базы данных pci.ids и MonitorsDB

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

./configure       \
    --prefix=/usr \
    --disable-blacklist || exit 1

# пакет не имеет набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (hardware identification and configuration data)
#
# hwdata contains various hardware identification and configuration data, such
# as the pci.ids database and MonitorsDB databases.
#
# Home page: https://github.com/vcrhonek/${PRGNAME}
# Download:  https://github.com/vcrhonek/${PRGNAME}/archive/v${VERSION}/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
