#! /bin/bash

PRGNAME="libpcap"

### libpcap (packet capture library)
# Библиотека для захвата сетевых пакетов на пользовательском уровне, которая
# предоставляет фреймворк для низкоуровневого мониторинга сети.

# Required:    no
# Recommended: no
# Optional:    bluez
#              libnl
#              libusb
#              dag    (https://www.endace.com/)
#              septel (https://www.intel.ru/content/www/ru/ru/homepage.html)

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

LIBNL="--without-libnl"
BLUETOOTH="no"
LIBUSB="no"

command -v genl-ctrl-list     &>/dev/null && LIBNL="--with-libnl"
command -v bluemoon           &>/dev/null && BLUETOOTH="yes"
[ -x /usr/lib/libusb-1.0.so ] && LIBUSB="yes"

./configure                  \
    --prefix=/usr            \
    "${LIBNL}"               \
    --enable-usb="${LIBUSB}" \
    --enable-bluetooth="${BLUETOOTH}" || exit 1

make || exit 1

# пакет не имеет набора тестов

# статическую библиотеку устанавливать не будем
sed -i '/INSTALL_DATA.*libpcap.a\|RANLIB.*libpcap.a/ s/^/#/' Makefile || exit 1
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (packet capture library)
#
# libpcap is a library for user-level packet capture. libpcap provides a
# portable framework for low-level network monitoring. Applications include
# network statistics collection, security monitoring, network debugging, etc.
# The tcpdump utility uses libpcap.
#
# Home page: https://www.tcpdump.org/
# Download:  https://www.tcpdump.org/release/${PRGNAME}-${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
