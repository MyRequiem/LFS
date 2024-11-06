#! /bin/bash

PRGNAME="sysvinit"

### Sysvinit (init, the parent of all processes)
# Программы для контроля запуска и выключение системы

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"

# по умолчанию пакет sysvinit устанавливает в том числе:
#    - ссылку в /bin pidof -> /sbin/killall5, но утилита /usr/bin/pidof уже
#       установлена с пакетом procps-ng
#    - /usr/sbin/logsave (уже установлена с пакетом e2fsprogs)
#    - /usr/bin/readbootlog
#    уже установленые с пакетом util-linux:
#    - /sbin/sulogin
#    - /usr/bin/last + ссылка lastb
#    - /usr/bin/mesg
#    - /usr/bin/utmpdump
#    - /usr/bin/wall
#
# применим патч, предотвращающий создание этих утилит и ссылок, а так же
# исправляет предупреждение компилятора
patch --verbose -Np1 -i \
    "/sources/${PRGNAME}-${VERSION}-consolidated-1.patch" || exit 1

# исправим пути установки
#    /bin  -> /usr/bin
#    /sbin -> /usr/sbin
sed -i 's/)\/bin/)\/usr\/bin/'   src/Makefile || exit 1
sed -i 's/)\/sbin/)\/usr\/sbin/' src/Makefile || exit 1

make || make -j1 || exit 1
# пакет не содержит набора тестов
make install DESTDIR="${TMP_DIR}"

source "${ROOT}/stripping.sh"      || exit 1
source "${ROOT}/update-info-db.sh" || exit 1
/bin/cp -vR "${TMP_DIR}"/* /

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (init, the parent of all processes)
#
# The Sysvinit package contains programs for controlling the startup, running,
# and shutdown of the system.
#
# Home page: https://savannah.nongnu.org/projects/${PRGNAME}
# Download:  https://github.com/slicer69/${PRGNAME}/releases/download/${VERSION}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
