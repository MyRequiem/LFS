#! /bin/bash

PRGNAME="net-tools"

### Net-tools (base Linux networking utilities)
# Основной набор инструментов, таких как route, arp и т. д., которые
# используется для настройки сетевой подсистемы ядра Linux.

# Required:    no
# Recommended: no
# Optional:    no

ROOT="/root/src/lfs"
source "${ROOT}/check_environment.sh"                  || exit 1
source "${ROOT}/unpack_source_archive.sh" "${PRGNAME}" || exit 1

VERSION="$(echo "${VERSION}" | cut -d _ -f 2)"
TMP_DIR="${BUILD_DIR}/package-${PRGNAME}-${VERSION}"
mkdir -pv "${TMP_DIR}"

# сборка и установка пакета должна производится в один поток, все утилиты
# устанавливаем в /usr/bin/
export BINDIR='/usr/bin' SBINDIR='/usr/bin' && \
yes "" |  make -j1 || exit 1
# пакет не имеет набора тестов
make -j1 install DESTDIR="${TMP_DIR}"
unset BINDIR SBINDIR

# утилиты ifconfig и hostname, уже были установлены в системе с пакетом
# inetutils (LFS), поэтому удалим их. Так же удалим утилиты, которые не
# подходят для нашей системы и лишние man-страницы
rm -f  "${TMP_DIR}/usr/bin"/{nis,yp}domainname
rm -f  "${TMP_DIR}/usr/bin"/{hostname,dnsdomainname,domainname,ifconfig}
rm -f  "${TMP_DIR}/usr/share/man/man8/ifconfig.8"
rm -rf "${TMP_DIR}/usr/share/man/man1"

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
# Download:  https://downloads.sourceforge.net/project/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
