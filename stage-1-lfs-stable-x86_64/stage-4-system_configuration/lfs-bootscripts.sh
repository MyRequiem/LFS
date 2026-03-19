#! /bin/bash

PRGNAME="lfs-bootscripts"

### LFS-Bootscripts (scripts to start/stop the LFS system)
# Пакет содержит набор скриптов для запуска/остановки системы LFS

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# исправим пути установки:
#    /lib  => /usr/lib
#    /sbin => /usr/sbin
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-fix-install-path.diff" || exit 1

# patch выше можно заменить на:
# sed -e 's|LIBDIR=${DESTDIR}/lib|LIBDIR=${DESTDIR}/usr/lib|' \
#     -e 's|SBIN=${DESTDIR}/sbin|SBIN=${DESTDIR}/usr/sbin|'   \
#     -i Makefile || exit 1

# у нас установлен Eudev вместо Udev, адаптируем скрипт запуска
# /etc/rc.d/init.d/udev
patch --verbose -Np1 -i \
    "${SOURCES}/${PRGNAME}-from-udev-to-eudev.diff" || exit 1

make install DESTDIR="${TMP_DIR}"

cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (scripts to start/stop the LFS system)
#
# The LFS-Bootscripts package contains a set of scripts to start/stop the LFS
# system at bootup/shutdown.
#
# Download: https://www.linuxfromscratch.org/lfs/downloads/development/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
