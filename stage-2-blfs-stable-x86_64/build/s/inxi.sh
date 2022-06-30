#! /bin/bash

PRGNAME="inxi"

### inxi (system information tool)
# Утилита командной строки для вывода информации об аппаратном обеспечении, ЦП,
# драйверов, Xorg, ядра, ОЗУ и множества другой полезной информации.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_VERSION="$(find "${SOURCES}" -type f \
    -name "${PRGNAME}-*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    rev | cut -d . -f 3- | cut -d - -f 1,2 | rev)"

VERSION="${ARCH_VERSION//-/_}"
BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${PRGNAME}-${ARCH_VERSION}"*.tar.?z* || exit 1
cd "${PRGNAME}-${ARCH_VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
MANDIR="/usr/share/man/man1"
mkdir -pv "${TMP_DIR}"{/usr/bin,"${MANDIR}"}

cp -a "${PRGNAME}" "${TMP_DIR}/usr/bin/${PRGNAME}"
chown root:root    "${TMP_DIR}/usr/bin/${PRGNAME}"
chmod 755          "${TMP_DIR}/usr/bin/${PRGNAME}"

cp -a "${PRGNAME}.1" "${TMP_DIR}${MANDIR}/${PRGNAME}.1"
chown root:root      "${TMP_DIR}${MANDIR}/${PRGNAME}.1"
chmod 644            "${TMP_DIR}${MANDIR}/${PRGNAME}.1"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (system information tool)
#
# inxi is a command line system information script built for console and IRC.
# It is also used a debugging tool for forum technical support to quickly
# ascertain users' system configurations and hardware. inxi shows system
# hardware, CPU, drivers, Xorg, Desktop, Kernel, gcc version(s), processes, RAM
# usage, and a wide variety of other useful information.
#
# Home page: https://github.com/smxi/${PRGNAME}
# Download:  https://github.com/smxi/${PRGNAME}/archive/${ARCH_VERSION}/${PRGNAME}-${ARCH_VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
