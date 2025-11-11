#! /bin/bash

PRGNAME="osinfo-db"

### osinfo-db (operating systems database)
# База данных osinfo предоставляет информацию об операционных системах и
# платформы гипервизора для облегчения автоматизированной установки и настройки
# новых виртуальных машин.

# Required:    osinfo-db-tools
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SRC_ARCH="$(find "${ROOT}/src" -type f -name "${PRGNAME}-[0-9]*.tar.?z*")"
VERSION="$(echo "${SRC_ARCH}" | rev | cut -d . -f 3- | cut -d - -f 1 | rev)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${TMP_DIR}"

# команда osinfo-db-import - пакет osinfo-db-tools
osinfo-db-import            \
    --root "${TMP_DIR}"     \
    --dir /usr/share/osinfo \
    "${SRC_ARCH}" || exit 1

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (operating systems database)
#
# The osinfo database provides information about operating systems and
# hypervisor platforms to facilitate the automated configuration and
# provisioning of new virtual machines.
#
# Home page: https://libosinfo.org/
# Download:  https://releases.pagure.org/libosinfo/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
