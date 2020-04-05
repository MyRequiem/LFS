#! /bin/bash

PRGNAME="sysvinit"

### Sysvinit
# программы для контроля запуска и выключение системы

# http://www.linuxfromscratch.org/lfs/view/9.0/chapter06/sysvinit.html

# Home page: https://savannah.nongnu.org/projects/sysvinit
# Download:  http://download.savannah.gnu.org/releases/sysvinit/sysvinit-2.95.tar.xz

ROOT="/"
source "${ROOT}check_environment.sh"                  || exit 1
source "${ROOT}unpack_source_archive.sh" "${PRGNAME}" || exit 1

# по умолчанию пакет sysvinit устанавливает в том числе:
#    - ссылку в /bin pidof -> /sbin/killall5, но утилита /bin/pidof уже
#       установлена с пакетом procps-ng
#    - /sbin/logsave (уже установлена с пакетом e2fsprogs)
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
patch --verbose -Np1 \
    -i "/sources/${PRGNAME}-${VERSION}-consolidated-1.patch" || exit 1

make || exit 1
# пакет не содержит набора тестов, поэтому сразу устанавливаем
make install

TMP_DIR="/tmp/pkg-${PRGNAME}-${VERSION}"
rm -rf "${TMP_DIR}"
mkdir -pv "${TMP_DIR}"
make ROOT="${TMP_DIR}" install

cd "${TMP_DIR}" || exit 1
rm -rf ./{bin,usr/{bin,share/man/man1}}

cat << EOF > "/var/log/packages/${PRGNAME}-${VERSION}"
# Package: ${PRGNAME} (init, the parent of all processes)
#
# The Sysvinit package contains programs for controlling the startup, running,
# and shutdown of the system.
#
# Home page: https://savannah.nongnu.org/projects/${PRGNAME}
# Download:  http://download.savannah.gnu.org/releases/${PRGNAME}/${PRGNAME}-${VERSION}.tar.xz
#
EOF

source "${ROOT}/write_to_var_log_packages.sh" \
    "${TMP_DIR}" "${PRGNAME}-${VERSION}"
