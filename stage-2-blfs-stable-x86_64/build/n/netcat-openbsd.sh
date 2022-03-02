#! /bin/bash

PRGNAME="netcat-openbsd"
ARCH_NAME="1.217-1"

### netcat-openbsd (reads and writes data across network connections)
# Переписанная OpenBSD версия утилиты netcat, включающая поддержку IPv6, прокси
# и сокеты Unix

# Required:    libbsd
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

VERSION="${ARCH_NAME/-/_}"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

SOURCES="${ROOT}/src"
tar xvf "${SOURCES}/${ARCH_NAME}"*.tar.?z* || exit 1
cd "${PRGNAME}-${ARCH_NAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MAN_DIR="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}"{/usr/bin,"${MAN_DIR}"}

make || exit 1

install -s -m 0755 nc "${TMP_DIR}/usr/bin/nc.openbsd"
(
    # ссылка в /usr/bin/
    #    nc -> nc.openbsd
    cd "${TMP_DIR}/usr/bin" || exit 1
    ln -svf nc.openbsd nc
)

# man страница
cp nc.1 "${TMP_DIR}${MAN_DIR}/nc.openbsd.1"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (reads and writes data across network connections)
#
# This package contains the OpenBSD rewrite of netcat, including support for
# IPv6, proxies, and Unix sockets
#
# Home page: https://github.com/duncan-roe/${PRGNAME}
# Download:  https://github.com/duncan-roe/${PRGNAME}/archive/refs/tags/${ARCH_NAME}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
