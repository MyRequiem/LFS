#! /bin/bash

PRGNAME="iproute2"

### IPRoute2 (IP routing utilities)
# Инструменты, используемые для администрирования многих расширенных функций
# IPv4-маршрутизации ядра linux

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# утилита 'arpd' не будет собрана, поскольку она зависит от пакета Berkeley DB,
# который устанавливается в BLFS, но каталог и man-страница для arpd все равно
# будут установлены. Предотвратим это:
sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8

make NETNS_RUN_DIR=/run/netns || make -j1 NETNS_RUN_DIR=/run/netns || exit 1
# пакет не содержит набора тестов
make SBINDIR=/usr/sbin install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (IP routing utilities)
#
# These are tools used to administer many advanced IP routing features in the
# kernel for basic and advanced IPV4-based networking. See Configure.help in
# the kernel documentation (search for iproute2) for more information on which
# kernel options these tools are used with.
#
# Home page: https://www.kernel.org/pub/linux/utils/net/${PRGNAME}/
# Download:  https://www.kernel.org/pub/linux/utils/net/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
