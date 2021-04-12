#! /bin/bash

PRGNAME="net-tools"

### Net-tools (base Linux networking utilities)
# Основной набор инструментов, таких как route, arp и т. д., которые
# используется для настройки сетевой подсистемы ядра Linux.

# Required:    no
# Recommended: no
# Optional:    no

### NOTE:
# В ходе конфигурации отвечаем 'y' на следующие вопросы (для минимальной
# конфигурации на остальные вопросы отвечаем 'n')
#    Does your system support GNU gettext? (I18N) [n] y
#    UNIX protocol family (HAVE_AFUNIX) [y] y
#    INET (TCP/IP) protocol family (HAVE_AFINET) [y] y
#    INET6 (IPv6) protocol family (HAVE_AFINET6) [y] y
#    Ethernet (generic) support (HAVE_HWETHER) [y] y
#    PPP (serial line) support (HAVE_HWPPP) [y] y
#    IPIP Tunnel support (HAVE_HWTUNNEL) [y] y
#    IP Masquerading support (HAVE_FW_MASQUERADE) [y] y

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d _ -f 2)"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# применим патч, который отключает создание утилит 'ifconfig' и 'hostname',
# которые уже установлены в системе с пакетом inetutils (LFS)
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-CVS_${VERSION}-remove_dups-1.patch" || exit 1

# исправим ошибку сборки с linux headers v4.8
sed -i '/#include <netinet\/ip.h>/d' iptunnel.c || exit 1

make config || exit 1
make || exit 1
# пакет не имеет набора тестов
# устанавливаем
make update DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vpR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (base Linux networking utilities)
#
# This is the core collection of tools such as 'route', 'arp', etc. used to
# configure networking subsystem of the Linux kernel.  You won't be able to do
# much networking without this package and the network-scripts.
#
# Home page: https://sourceforge.net/projects/${PRGNAME}/
# Download:  http://anduin.linuxfromscratch.org/BLFS/${PRGNAME}/${PRGNAME}-CVS_${VERSION}.tar.gz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
