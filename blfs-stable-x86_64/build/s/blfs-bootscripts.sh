#! /bin/bash

PRGNAME="blfs-bootscripts"

#### BLFS Boot Scripts
# Пакет содержит инициализационные скрипты для многих пакетов BLFS. Скрипты
# устанавливаются в /etc/sysconfig, /lib/services и в /etc/init.d. Так же
# устанавливаются необходимые символические ссылки.
#
# Установка скрипта для определенного пакета:
#    # make install-<init-script>
#    например:
#    # make install-service-dhcpcd

# http://www.linuxfromscratch.org/blfs/view/9.0/introduction/bootscripts.html

# Home page: http://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/
# Download:  http://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-20190609.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# просто переместим исходники в /root
cd .. || exit 1
mv "${PRGNAME}-${VERSION}" "/root/${PRGNAME}"
