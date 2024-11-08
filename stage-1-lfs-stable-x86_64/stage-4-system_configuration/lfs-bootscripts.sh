#! /bin/bash

PRGNAME="lfs-bootscripts"

### LFS-Bootscripts (scripts to start/stop the LFS system)
# Пакет содержит набор скриптов для запуска/остановки системы LFS при
# загрузке/выключении

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим пути установки в Makefile:
#    /lib  ->  /usr/lib
#    /sbin -> /usr/sbin
sed -e 's|LIBDIR=${DESTDIR}/lib|LIBDIR=${DESTDIR}/usr/lib|' \
    -e 's|SBIN=${DESTDIR}/sbin|SBIN=${DESTDIR}/usr/sbin|'   \
    -i Makefile || exit 1

make install DESTDIR="${TMP_DIR}"

cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (scripts to start/stop the LFS system)
#
# The LFS-Bootscripts package contains a set of scripts to start/stop the LFS
# system at bootup/shutdown.
#
# Download: http://www.linuxfromscratch.org/lfs/downloads/stable/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
