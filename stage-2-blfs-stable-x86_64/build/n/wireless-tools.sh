#! /bin/bash

PRGNAME="wireless-tools"

### wireless-tools (utilities for wireless networking)
# Набор инструментов, позволяющих управлять беспроводными соединениями:
# ifrename, iwconfig, iwevent, iwgetid, iwlist, iwpriv, iwspy

# Required:    no
# Recommended: no
# Optional:    no

###
# Конфигурация ядра
###
#    CONFIG_PCCARD=m
#    CONFIG_YENTA=m

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh" || exit 1

SOURCES="${ROOT}/src"
ARCH_NAME="${PRGNAME//-/_}"
VERSION="$(find "${SOURCES}" -type f \
    -name "${ARCH_NAME}.*.tar.?z*" 2>/dev/null | sort | head -n 1 | \
    cut -d . -f 2)"

BUILD_DIR="/tmp/build-${PRGNAME}-${VERSION}"
rm -rf "${BUILD_DIR}"
mkdir -pv "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit 1

tar xvf "${SOURCES}/${ARCH_NAME}.${VERSION}"*.tar.?z* || exit 1
cd "${ARCH_NAME}.${VERSION}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# устраним проблему, возникающую если доступно несколько беспроводных сетей
patch --verbose -Np1 -i \
    "${SOURCES}/${ARCH_NAME}-${VERSION}-fix_iwlist_scanning-1.patch" || exit 1

make || exit 1
# пакет не имеет набора тестов
make                        \
    PREFIX="${TMP_DIR}/usr" \
    INSTALL_MAN="${TMP_DIR}/usr/share/man" install

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (utilities for wireless networking)
#
# The Wireless Tools (WT) package is a set of tools allowing manipulation of
# the Wireless Extensions. They use a textual interface to support the full
# Wireless Extension.
#
#  ifrename - renames network interfaces based on various static criteria
#  iwconfig - configures a wireless network interface
#  iwevent  - displays wireless events generated by drivers and setting changes
#  iwgetid  - reports ESSID, NWID or AP/Cell Address of wireless networks
#  iwlist   - gets detailed wireless information from a wireless interface
#  iwpriv   - configures private parameters of a wireless network interface
#  iwspy    - gets wireless statistics from specific node
#
# Home page: https://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/Tools.html
# Download:  https://hewlettpackard.github.io/${PRGNAME}/${ARCH_NAME}.${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
