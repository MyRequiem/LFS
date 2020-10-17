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

# утилиту arpd создавать не будем, так как она зависит от Berkeley DB, которая
# у нас в LFS системе не установлена
sed -i /ARPD/d Makefile || exit 1
# тем не менее man-страницы для arpd все равно будут установлены, удалим их
rm -fv man/man8/arpd.8

# также необходимо отключить сборку двух модулей, для которых требуется
# iptables
sed -i 's/.m_ipt.o//' tc/Makefile || exit 1

make || make -j1 || exit 1
# пакет не содержит набора тестов
make DOCDIR="/usr/share/doc/${PRGNAME}-${VERSION}" install DESTDIR="${TMP_DIR}"

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
