#! /bin/bash

PRGNAME="lfs-bootscripts"

### LFS-Bootscripts
# Пакет содержит набор скриптов для запуска/остановки системы LFS при
# загрузке/выключении

# http://www.linuxfromscratch.org/lfs/view/stable/chapter07/bootscripts.html

# Download: http://www.linuxfromscratch.org/lfs/downloads/9.1/lfs-bootscripts-20191031.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

make install
make install DESTDIR="${TMP_DIR}"

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (scripts to start/stop the LFS system)
#
# The LFS-Bootscripts package contains a set of scripts to start/stop the LFS
# system at bootup/shutdown. The configuration files and procedures needed to
# customize the boot process are described in the following sections.
#
# Download: http://www.linuxfromscratch.org/lfs/downloads/9.1/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
